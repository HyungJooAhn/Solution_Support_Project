package com.seculayer.web.tist.stix;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import java.util.StringTokenizer;
import org.mitre.stix.stix_1.STIXPackage;

public class STIXParser {
	public STIXParser(){}

	public ArrayList<Object> stixParsing(String stixStr){
		STIXPackage stixPackage = STIXPackage.fromXMLString(stixStr);
		ArrayList<Object> resultMap = makeDepthMap(stixPackage.getIndicators().toXMLString());
		return resultMap;
	}
	public ArrayList<Object> makeDepthMap(String xmlStr){
		ArrayList<String> elementList = new ArrayList<String>();
		ArrayList<Map<String, Integer>> depthArray = new ArrayList<Map<String, Integer>>();
		genDepthMap(xmlStr,depthArray,elementList);
		ArrayList<Object> depthElement =  new ArrayList<Object>();
		depthElement.add(elementList);
		depthElement.add(depthArray);
		
		return depthElement;
	}
	
	public static void genDepthMap(String xmlStr,ArrayList<Map<String, Integer>> depthArray, ArrayList<String> elementList){
		int depth = 0;
		ArrayList<String> tokenizerList = new ArrayList<String>();
		
		StringTokenizer st = new StringTokenizer(xmlStr, "<");
		while(st.hasMoreTokens()){
			String mstr = st.nextToken();
			if((mstr.indexOf(" ") >= 0) && (mstr.indexOf(" ") < mstr.indexOf(">"))){
				tokenizerList.add(mstr.substring(0, mstr.indexOf(" ")));	
			}else{
				tokenizerList.add(mstr.substring(0, mstr.indexOf(">")));
			}
		}
		
		for(int i=0; i<tokenizerList.size(); i++){
			if(i < tokenizerList.size()-1){
				if('/' == tokenizerList.get(i).charAt(0)){
					if('/' == tokenizerList.get(i+1).charAt(0)){
						depth --;
					}
				}else{
					Map<String, Integer> depthMap = new HashMap<String, Integer>();
					depthMap.put(tokenizerList.get(i), depth);
					if('/' != tokenizerList.get(i).charAt(tokenizerList.get(i).length()-1)){
						if('/' != tokenizerList.get(i+1).charAt(0)){
							depth ++;
						}	
					}else{
						if('/' == tokenizerList.get(i+1).charAt(0)){
							depth --;
						}
					}
					depthArray.add(depthMap);
				}
			}
		}
		
		st = new StringTokenizer(xmlStr, "<");
		while(st.hasMoreTokens()){
				String mstr = st.nextToken();
				if('/' != mstr.charAt(0)){
					elementList.add(mstr);
				}
		}
	}
	
}
