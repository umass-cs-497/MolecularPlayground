/*
 * Copyright 2011 University of Massachusetts
 *
 * File: MPJmolApp.java
 * Description: Molecular Playground Jmol interface component/application
 * Author: Adam Williams
 *
 * This class uses the Naga asynchronous socket IO package, the JSON.org JSON package and 
 * Jmol (currently 11.8.2).  A few small modifications must be made to
 * org.jmol.viewer.Viewer: the methods zoomByFactor, rotateXYBy, and translateXYBy must
 * be made public.  No other changes were made to the Jmol source.
 */
package org.molecularplayground;

import java.util.*;
import java.io.*;
import java.awt.*;
import javax.swing.*;
import java.awt.image.*;
import java.awt.Robot;
import org.jmol.adapter.smarter.SmarterJmolAdapter;
import org.jmol.api.JmolAdapter;
import org.jmol.api.JmolSimpleViewer;
import org.jmol.api.JmolStatusListener;
import org.jmol.viewer.JmolConstants;
import org.jmol.viewer.Viewer;
import org.jmol.util.Logger;
import naga.NIOService;
import naga.NIOSocket;
import naga.SocketObserver;
import naga.packetwriter.RawPacketWriter;
import naga.packetreader.AsciiLinePacketReader;
import org.json.*;

public class MPJmolApp implements JmolStatusListener {

	Viewer jmolViewer;
	NIOService service;
	NIOSocket socket;
	int port;
	boolean halt;
	boolean isPaused;
	long lastMoveTime;
	boolean wasSpinOn;
	
	JLabel bannerLabel;
	JFrame bannerFrame;
	String bannerText;
	String altBannerText = "More at MolecularPlayground.org";
	boolean altBannerOn;
	boolean showingAltBanner;
	boolean hasBannerImage;
	boolean hasAltBannerImage;
	long altBannerDelay;
	long lastBannerSwap;
	long lastContentLoad;
	
	String bannerImagePath;
	String altBannerImagePath;
	
	public static void main(String args[])
	{
		int portArg = 31415;
		if(args.length > 0) {
			portArg = Integer.parseInt(args[0]);
		}
		try {
		Robot r = new Robot();
		r.mouseMove(1024,768);
		} catch (Exception e) {}
		new MPJmolApp(portArg);
	}
	
	public MPJmolApp(int port)
	{
		halt = false;
		this.port = port;
				
		isPaused = false;
		lastMoveTime = 0;
		wasSpinOn = false;
		
		hasBannerImage = false;
		hasAltBannerImage = false;
		showingAltBanner = false;
		altBannerOn = false;
		
		bannerImagePath = System.getProperty("user.dir") + "/Images/banner.jpg";
		altBannerImagePath = System.getProperty("user.dir") + "/Images/banner_alt.jpg";
	
		JFrame appFrame = new JFrame("MPJmolApp");
		appFrame.setUndecorated(true);
		appFrame.setBackground(new Color(0, 0, 0, 0));
		Container contentPane = appFrame.getContentPane();
		JmolPanel jmolPanel = new JmolPanel();
		contentPane.add(jmolPanel);
		appFrame.setSize(1024, 768);
		appFrame.setBounds(0, 0, 1024, 768);
		appFrame.setVisible(true);
		
		bannerFrame = new JFrame("Banner");
		bannerFrame.setUndecorated(true);
		bannerFrame.setSize(1024,75);
		bannerFrame.setBounds(0, 0, 1024, 75);
		bannerFrame.setBackground(Color.WHITE);
		
		bannerLabel = new JLabel("<html></html>", SwingConstants.CENTER) {
			public void paintComponent(Graphics g) {
				if(showingAltBanner && hasAltBannerImage) {
					Image img = new ImageIcon(altBannerImagePath).getImage();
					g.drawImage(img, 0, 0, null);
				}
				else if(!showingAltBanner && hasBannerImage) {
					Image img = new ImageIcon(bannerImagePath).getImage();
					g.drawImage(img, 0, 0, null);
				}
				super.paintComponent(g);
			}
		};
		bannerLabel.setPreferredSize(bannerFrame.getSize());
		bannerLabel.setFont(new Font("Helvetica", Font.BOLD, 30));
		bannerLabel.setForeground(Color.BLACK);
		bannerFrame.getContentPane().add(bannerLabel, BorderLayout.CENTER);
		bannerFrame.setVisible(true);
		bannerFrame.setAlwaysOnTop(true);
				
		jmolViewer = jmolPanel.getViewer();
		jmolViewer.setJmolStatusListener(this);
		jmolViewer.script("set frank off;set antialiasdisplay off;");
				
		/*
		 * Separate sockets are used for incoming and outgoing messages,
		 * since communication to/from the Hub is completely asynchronous
		 *
		 * All messages are sent as JSON strings, terminated by a CR/LF.
		 */
		try {
			service = new NIOService();
			socket = service.openSocket("127.0.0.1", port);
			socket.setPacketReader(new AsciiLinePacketReader());
			socket.setPacketWriter(new RawPacketWriter());
			
			socket.listen(new SocketObserver() {
				
				public void connectionOpened(NIOSocket nioSocket)
				{
					try {
						JSONObject json = new JSONObject();
						json.put("source","Jmol");
						json.put("type", "login");
						String jsonString = json.toString()+"\r\n";
						nioSocket.write(jsonString.getBytes("UTF-8"));
					}
					catch(Exception e) {
						e.printStackTrace();
					}
				}
				
				public void packetSent(NIOSocket nioSocket, Object tag)
				{
				}
				
				public void packetReceived(NIOSocket nioSocket, byte[] packet)
				{
					processMessage(packet);
				}
				
				public void connectionBroken(NIOSocket nioSocket, Exception exception)
				{
				}
			});
					
			while(!halt) {
				service.selectNonBlocking();
				
				long now = Calendar.getInstance().getTimeInMillis();
				
				if(altBannerOn && now - lastBannerSwap >= (altBannerDelay * 1000)) {
					showingAltBanner = !showingAltBanner;
					updateBannerText();
					lastBannerSwap = now;
				}				
				
				// No commands for 5 seconds = unpause/restore Jmol
				if(isPaused && now - lastMoveTime > 5000) {
					jmolViewer.restoreRotation("playground-save", 1);
					jmolViewer.script("resume");
					isPaused = false;
					jmolViewer.setSpinOn(wasSpinOn);
					wasSpinOn = false;
				}
				
				Thread.sleep(50);				
			}
			socket.close();
			System.exit(0);
		}
		catch(Exception e) {
			e.printStackTrace();
			service.close();
		}
	}
	
	private void updateBannerText() {
		Color color = Color.BLACK;
		if((showingAltBanner && hasAltBannerImage) || (!showingAltBanner && hasBannerImage)) {
			color = Color.WHITE;
		}
		bannerLabel.setForeground(color);
		String text = (showingAltBanner) ? altBannerText : bannerText;
		bannerLabel.setText("<html><center>"+text+"</center></html>");
	}
	
	private void processMessage(byte[] packet)
	{
		try {
			String msg = new String(packet);
			JSONObject json = new JSONObject(msg);
			if(json.getString("type").equals("move")) {
				
				// Delay a bit after a content load so it doesn't pause on a blank screen
				long now = Calendar.getInstance().getTimeInMillis();
				if(now - lastContentLoad < 3000) return;
				
				// Pause the script and save the state when interaction starts
				if(!isPaused ) {
					jmolViewer.script("pause");
					jmolViewer.saveOrientation("playground-save");
					isPaused = true;
					wasSpinOn = jmolViewer.getSpinOn();
					jmolViewer.setSpinOn(false);
				}
				
				lastMoveTime = Calendar.getInstance().getTimeInMillis();
				
				String style = json.getString("style");
				
				if(style.equals("zoom")) {
					float zoomFactor = jmolViewer.getZoomPercentFloat()/100.0f;
					zoomFactor = ((float)json.getDouble("scale"))/zoomFactor;
					jmolViewer.zoomByFactor(zoomFactor);
				}
				else if(style.equals("rotate")) {
					int x = (int)json.getDouble("x");
					int y = (int)json.getDouble("y");
					jmolViewer.rotateXYBy(x,y);
				}
				else if(style.equals("translate")) {
					int x = (int)json.getDouble("x");
					int y = (int)json.getDouble("y");
					jmolViewer.translateXYBy(x,y);
				}
			}
			else if(json.getString("type").equals("content")) {
				processContent(json);
			}
			else if(json.getString("type").equals("command")) {
				String command = json.getString("command");	
				jmolViewer.script(command);
			}
			else if(json.getString("type").equals("quit")) {
				halt = true;
				System.out.println("I should quit");
			}	
		}
		catch(Exception e) {
			e.printStackTrace();
		}
	}
	
	private void processContent(JSONObject json) throws Exception
	{
		String key = json.getString("key");
		String path = json.getString("path");
		String contentPath = System.getProperty("user.dir") + path + key;
		String metaPath = contentPath + "/meta.json";
		altBannerOn = json.getString("altBanner").equals("on");
		if(altBannerOn) {
			altBannerText = json.getString("altBannerText");
			altBannerDelay = json.getInt("altBannerDelay");
			System.out.println("alt banner on: " + altBannerText + " delay: " + altBannerDelay);
		}
		
		File bannerImage = new File(bannerImagePath);
		hasBannerImage = bannerImage.exists();
		File altBannerImage = new File(altBannerImagePath);
		hasAltBannerImage = altBannerImage.exists();
		
		FileInputStream jsonFile = new FileInputStream(metaPath);
		JSONObject contentJSON = new JSONObject(new JSONTokener(jsonFile));
		bannerText = "";
		showingAltBanner = false;
		updateBannerText();
		jmolViewer.script("exit");
		jmolViewer.script("zap");
		jmolViewer.script("cd " + contentPath);
		
		//Find startup script
		String startupScript = null;
		JSONArray scripts = contentJSON.getJSONArray("scripts");
		for(int i = 0; i < scripts.length(); i++) {
			JSONObject scriptInfo = scripts.getJSONObject(i);
			if(scriptInfo.getString("startup").equals("yes")) {
				startupScript = scriptInfo.getString("filename");
				break;
			}
		}
						
		jmolViewer.script("script " + startupScript);
		if(contentJSON.getString("banner").equals("off")) {
			bannerFrame.setVisible(false);
			bannerText = "";
		}
		else {
			bannerFrame.setVisible(true);
			bannerText = contentJSON.getString("banner_text");
		}
		updateBannerText();
		lastContentLoad = lastBannerSwap = Calendar.getInstance().getTimeInMillis();
	}
	
	private void sendMessage(JSONObject json)
	{	
		try {
			String jsonString = json.toString()+"\r\n";
			socket.write(jsonString.getBytes("UTF-8"));
		}
		catch(Exception e) {
			e.printStackTrace();
		}	
	}
	
  	static class JmolPanel extends JPanel {
    	Viewer viewer;
    	JmolAdapter adapter;
    	
    	JmolPanel() 
    	{
      		adapter = new SmarterJmolAdapter();
      		viewer = (Viewer)Viewer.allocateViewer(this, adapter, null, null, null, null, null);
    	}

    	public Viewer getViewer() 
    	{
      		return viewer;
    	}

    	final Dimension currentSize = new Dimension();
    	final Rectangle rectClip = new Rectangle();

    	public void paint(Graphics g) 
    	{
      		getSize(currentSize);
      		g.getClipBounds(rectClip);
      		viewer.renderScreenImage(g, currentSize, rectClip);
    	}
	}
	
	public boolean notifyEnabled(int type) {
	// indicate here any callbacks you will be working with.
	// some of these flags are not tested. See org.jmol.viewer.StatusManager.java
		switch (type) {
				case JmolConstants.CALLBACK_SCRIPT: return true;
		}
		return false;
	}
	
	public void notifyCallback(int type, Object[] data) {
	// this method as of 11.5.23 gets all the callback notifications for
	// any embedding application or for the applet.
	// see org.jmol.applet.Jmol.java and org.jmol.openscience.app.Jmol.java
	
	// data is an object set up by org.jmol.viewer.StatusManager
	// see that class for details.
	// data[0] is always blank -- for inserting htmlName
	// data[1] is either String (main message) or int[] (animFrameCallback only)
	// data[2] is optional supplemental information such as status info
	//         or sometimes an Integer value
	// data[3] is more optional supplemental information, either a String or Integer
	// etc. 
	
		/*
		 * MP_DONE is the end-of-script marker.
		 * When Jmol gets to this message, we tell the Hub that we're done
		 * with the script and need the name of the next one to load.
		 */
		switch (type) {
			case JmolConstants.CALLBACK_SCRIPT:
				String msg = (String)data[1];
				if(msg.equals("MP_DONE")) {
					try {
						JSONObject json = new JSONObject();
						json.put("source", "Jmol");
						json.put("type","contentRequest");
						sendMessage(json);
					}
					catch(Exception e) {
						e.printStackTrace();
					}
				}
			break;
			default:
			break;
		}
	}  
	
	private void notifyAtomPicked(int atomIndex, String strInfo) {
		System.out.println(strInfo);
	}
	
	
	/* (non-Javadoc)
	* @see org.jmol.api.JmolStatusListener#showUrl(java.lang.String)
	*/
	public void showUrl(String url) {
		System.out.println(url);
	}
	
	/* (non-Javadoc)
	* @see org.jmol.api.JmolStatusListener#createImage(java.lang.String, java.lang.String, int)
	*/
	public void createImage(String file, String type, int quality) {
	//
	}
	
	/* (non-Javadoc)
	* @see org.jmol.api.JmolStatusListener#functionXY(java.lang.String, int, int)
	*/
	public float[][] functionXY(String functionName, int nx, int ny) {
		return null;
	}
	
	/* (non-Javadoc)
	* @see org.jmol.api.JmolStatusListener#functionXY(java.lang.String, int, int)
	*/
	public float[][][] functionXYZ(String functionName, int nx, int ny, int nz) {
		return null;
	}
	
	/* (non-Javadoc)
	* @see org.jmol.api.JmolStatusListener#sendConsoleEcho(java.lang.String)
	*/
	private void sendConsoleEcho(String strEcho) {
	//
	}
	
	/* (non-Javadoc)
	* @see org.jmol.api.JmolStatusListener#sendConsoleMessage(java.lang.String)
	*/
	private void sendConsoleMessage(String strStatus) {
	//
	}
	
	/* (non-Javadoc)
	* @see org.jmol.api.JmolStatusListener#setCallbackFunction(java.lang.String, java.lang.String)
	*/
	public void setCallbackFunction(String callbackType, String callbackFunction) {
	//
	}
	
	/* (non-Javadoc)
	* @see org.jmol.api.JmolStatusListener#eval(java.lang.String)
	*/
	public String eval(String strEval) {
		return null;
	}
	
	public Hashtable getRegistryInfo() {
		return null;
	}
	
	public String createImage(String file, String type, Object text_or_bytes, int quality) {
		return null;
	}
	
	public String dialogAsk(String type, String data) {
		return null;
	}
	
	public void resizeInnerPanel(String data) {
	}

}