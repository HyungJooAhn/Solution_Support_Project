package com.seculayer.web.tist;

import java.util.List;
import java.util.Map;

import org.apache.log4j.Logger;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping(value = "/tist/")
public class VXShareService {
	
	static Logger logger = Logger.getLogger(VXShareService.class);
	
	public void divListData(List<Map<String,Object>> list, List<Map<String,Object>> list_1, List<Map<String,Object>> list_2){
		int listSize = list.size();
		if(listSize < 10){
			for(int i=0; i<listSize; i++){
				Map<String, Object> dmap = list.get(i);
				list_1.add(dmap);
			}
		}else if(listSize < 20){
			for(int i=0; i<10; i++){
				Map<String, Object> dmap = list.get(i);
				list_1.add(dmap);
			}
			for(int i=10; i<listSize; i++){
				Map<String, Object> dmap = list.get(i);
				list_2.add(dmap);
			}
		}else if(listSize == 20){
			for(int i=0; i<10; i++){
				Map<String, Object> dmap = list.get(i);
				list_1.add(dmap);
			}
			for(int i=10; i<listSize; i++){
				Map<String, Object> dmap = list.get(i);
				list_2.add(dmap);
			}
		}
	}
	
}
