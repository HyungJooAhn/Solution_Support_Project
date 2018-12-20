package com.seculayer.web.tist.taxii;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.net.MalformedURLException;
import java.net.URI;
import java.net.URISyntaxException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.GregorianCalendar;
import java.util.List;
import java.util.Map.Entry;
import java.util.Properties;
import java.util.Set;

import javax.xml.bind.JAXBException;
import javax.xml.bind.Marshaller;
import javax.xml.datatype.DatatypeConfigurationException;
import javax.xml.datatype.DatatypeFactory;
import javax.xml.datatype.XMLGregorianCalendar;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;

import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.OptionBuilder;
import org.apache.commons.cli.Options;
import org.mitre.taxii.ContentBindings;
import org.mitre.taxii.messages.xml11.ContentBlock;
import org.mitre.taxii.messages.xml11.MessageHelper;
import org.mitre.taxii.messages.xml11.PollRequest;
import org.mitre.taxii.messages.xml11.PollResponse;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.w3c.dom.ls.DOMImplementationLS;
import org.w3c.dom.ls.LSSerializer;

public class PollClient extends AbstractClient {
	private static final SimpleDateFormat fmt = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");

    public PollClient() {
        super();
    }

    public ArrayList<Object> pullService(String[] args, String collectionName, String service_path) throws MalformedURLException, JAXBException, IOException, URISyntaxException, Exception {
    	ArrayList<Object> result = null;
    	String url = args[1] + service_path;
        Options options = cli.getOptions();
        options.addOption("collection", true, "Data Collection to poll. Defaults to 'default'.");
        options.addOption("begin_timestamp", true, "The begin timestamp (format: YYYY-MM-DDTHH:MM:SS.ssssss+/-hh:mm) for the poll request. Defaults to none.");
        options.addOption("end_timestamp", true, "The end timestamp (format: YYYY-MM-DDTHH:MM:SS.ssssss+/-hh:mm) for the poll request. Defaults to none.");
        options.addOption("subscription_id", true, "The Subscription ID for the poll request. Defaults to none.");
        options.addOption("dest_dir", true, "The directory to save Content Blocks to. Defaults to the current directory.");
        options.addOption("proc_name", true, "process name");
        options.addOption("subproc", true, "subprocess name");
        options.addOption("env", true, "environment enumeration");
        
        options.addOption(OptionBuilder.withArgName("extheaders").hasArgs(2)
        				.withValueSeparator(':')
        				.withDescription("Extend headers key:value pairs")
        				.create("X"));

        cli.parse(args);
        CommandLine cmd = cli.getCmd();

        String collection = cmd.getOptionValue("collection", collectionName);
        String subId = cmd.getOptionValue("subscription_id", null);
        String dest = cmd.getOptionValue("dest_dir", ".");
        
        String sessionID = MessageHelper.generateMessageId();
        
		Date lastTime = getLatestTime(dest);
		Date now = new Date();

        taxiiClient = generateClient(cmd);
        
        Properties props = cmd.getOptionProperties("X");
        
        PollRequest request = factory.createPollRequest()
                .withMessageId(sessionID)
                .withCollectionName(collection);
        
        if (!props.isEmpty()) {
        	Set<Entry<Object,Object>> s = props.entrySet();
        	for (Entry<Object,Object> e : s) {
        		String key = e.getKey().toString();
        		String val = e.getValue().toString();
        		MessageHelper.addExtendedHeader(request, new URI(key), val);
        	}
        }

        if (null != subId) {
            request.setSubscriptionID(subId);
        } else {
            request.withPollParameters(factory.createPollParametersType());
        }

    	Calendar gc = GregorianCalendar.getInstance();
    	gc.setTime(lastTime);
    	XMLGregorianCalendar beginTime = DatatypeFactory.newInstance().newXMLGregorianCalendar((GregorianCalendar)gc).normalize();
    	beginTime.setFractionalSecond(null);
       // request.setExclusiveBeginTimestamp(beginTime);

    	gc.setTime(now);
    	XMLGregorianCalendar endTime = DatatypeFactory.newInstance().newXMLGregorianCalendar((GregorianCalendar)gc).normalize();
    	endTime.setFractionalSecond(null);
       // request.setInclusiveEndTimestamp(endTime);
        
        Object response = doCall(request, url);

        if (response instanceof PollResponse) {
        	result = handleResponse(dest, (PollResponse) response);
        }
        
        return result;
    }

    private ArrayList<Object> handleResponse(String dest, PollResponse response) {
    	ArrayList<Object> responseResult = new ArrayList<Object>();
    	
        try {
        	
            List<ContentBlock> blocks =  response.getContentBlocks();
            
            if (blocks.size() > 0) {
            	
	            DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
	            dbf.setNamespaceAware(true);
	            DocumentBuilder db = dbf.newDocumentBuilder();
	           
	            for (ContentBlock cb : blocks) {

	                try {
	                	 String binding = cb.getContentBinding().getBindingId();
	                	 String dateString;
	                     String format;
	                     
	                    if (ContentBindings.CB_STIX_XML_10.equals(binding)) {
	                        format = "_STIX10_";
	                    } else if (ContentBindings.CB_STIX_XML_101.equals(binding)) {
	                        format = "_STIX101_";
	                    } else if (ContentBindings.CB_STIX_XML_11.equals(binding)) {
	                        format = "_STIX11_";
	                    } else if (ContentBindings.CB_STIX_XML_111.equals(binding)) {
	                        format = "_STIX111_";
	                    } else { // Format and extension are unknown
	                        format = "";
	                    }
	                    if (null != cb.getTimestampLabel()) {
	                        dateString = 't' + cb.getTimestampLabel().toXMLFormat(); // This probably won't work due to illegal characters.
	                    } else {
	                        try {
	                            GregorianCalendar gc = new GregorianCalendar();
	                            gc.setTime(new Date()); // Now.
	                            XMLGregorianCalendar now = DatatypeFactory.newInstance().newXMLGregorianCalendar(gc);
	                            dateString = "s" + now.toXMLFormat();
	                        } catch (DatatypeConfigurationException ex) {
	                            dateString = "";
	                        }
	                    }
	                    String stixDivName = response.getCollectionName() + format + dateString;
	                    stixDivName = stixDivName.replaceAll("[\\*:<>\\/\\?|]", "");
	                	
	                    Marshaller m = taxiiXml.createMarshaller(true);
	                    
	                    Document doc = db.newDocument();
	                    m.marshal(cb, doc);
	                    
	                    Element root = doc.getDocumentElement();
	                    Node contentNode = root.getFirstChild().getNextSibling();
	                    
	                    if (contentNode != null) {
	                        NodeList contentChildren = contentNode.getChildNodes();
	                        int numChildren = contentChildren.getLength();
	                        String responseStr = "";
	                        for (int count = 0; count < numChildren; count++) {
	                            Node child = contentChildren.item(count);
	                            
	                            DOMImplementationLS domImpl = (DOMImplementationLS)child.getOwnerDocument().getImplementation();
	                            LSSerializer serializer = domImpl.createLSSerializer();
	                            serializer.getDomConfig().setParameter("xml-declaration", false);
	                                                        
	                            String childStr = serializer.writeToString(child);
	                            responseStr += childStr;
	                        }
	                        responseResult.add(stixDivName);
	                        responseResult.add(responseStr);
	                    }
	                    else {
	                    	responseResult.add(-1);
		                    responseResult.add("No Content Blocks found for Response");
	        	        }
	                    
	                } catch (JAXBException ex) {
	                	responseResult.add(-1);
	                    responseResult.add(ex.getMessage());
	                    return responseResult;
	                }
	            }
	            responseResult.add(0, 0);
            } else {
            	responseResult.add(-1);
                responseResult.add("There were no Content Blocks returned");
                return responseResult;
	        }
           
        } catch (ParserConfigurationException ex) {
        	responseResult.add(-1);
            responseResult.add(ex.getMessage());
            return responseResult;
        }
        return responseResult;
    }
    
	/**
	 * Read file with last download timestamp and return Date.  Rewrite file with current date for next time.
	 * @return Date
	 */
	public Date getLatestTime(String destDir) {
		File dlDir = new File(destDir+"/..");
		if (!dlDir.exists()) {
			dlDir.mkdirs();
		}

		Date lastTime = null;
		BufferedReader rd = null;
		lastTime = new Date();
		try {
			File fn = new File(dlDir,"lasttime.txt");
			if (fn.exists()) {
				// read the date from the last time this program was called.
				rd = new BufferedReader(new FileReader(fn));
				lastTime = fmt.parse(rd.readLine());
			}
			
		} catch (ParseException e) {
			System.out.println("couldn't parse date, using current time" +  e.getMessage());
		} catch (FileNotFoundException e) {
			System.out.println("File doesn't exist, using current time" + e.getMessage());
		} catch (IOException e) {
			System.out.println("couldn't read lasttime file, using current time" + e.getMessage());
		} finally {
			if (rd != null)
				try {
					rd.close();
				} catch (IOException e) {
					System.out.println(e.getMessage());
				}
		}
		
		// write out the current date to the file
		File fn = new File(dlDir,"lasttime.txt");
		FileWriter fw;
		try {
			fw = new FileWriter(fn);
			fw.write(fmt.format(new Date()));
			fw.close();
		} catch (IOException e) {
			System.out.println(e.getMessage());
		}

		return lastTime;
	}
}
