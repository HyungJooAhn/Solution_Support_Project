package com.seculayer.web.tist;

import java.io.File;
import java.net.InetAddress;
import java.net.UnknownHostException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

import org.apache.ibatis.session.SqlSession;
import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import com.seculayer.web.common.Configuration;
import com.seculayer.web.common.ProcRuntimeHandler;
import com.seculayer.web.common.util.Path;
import com.seculayer.web.tist.dao.HubAndSpokeTaxiiDAO;


@Controller
@RequestMapping(value = "/tist/")
public class HubAndSpokeTaxiiService {
	@Autowired private SqlSession sqlSession;
	private static ProcRuntimeHandler runtimeHandler = new ProcRuntimeHandler(false);
	private static Configuration conf = new Configuration(true);
	private static final String INTELLIGENCE_CENTER_SERVER_HOME = "/Seculayer/app/intelligence_server"; 
	static Logger logger = Logger.getLogger(HubAndSpokeTaxiiService.class);
	
	public Map<String, String> getStatus(){
		Map<String, String> result = new HashMap<String, String>();
		try{
			String cmd = "ps -ef | grep IntelligenceServer | grep -v grep ";
			StringBuffer buffer = runtimeHandler.exeCommand(cmd);
			String commandResult = buffer.toString().trim(); 
	
			if("".equals(commandResult)){
				result.put("server_status", "0");
			}else{
				result.put("server_status", "1");
			}
			
			cmd = "netstat -tnlp | grep 9720 | grep -v grep";
			buffer = runtimeHandler.exeCommand(cmd);
			commandResult = buffer.toString();
			
			if("".equals(commandResult)){
				result.put("service_status", "0");
			}else{
				result.put("service_status", "1");
			}
		}catch(Exception e){
			result = null;
		}
		return result;
	}
	
	public void initServerInfo() throws UnknownHostException{
		HubAndSpokeTaxiiDAO dao = sqlSession.getMapper(HubAndSpokeTaxiiDAO.class);
		Map<String, Object> param = new HashMap<String, Object>();
		
		String serverDefaultName = "TAXII Server";
		String serverIP = InetAddress.getLocalHost().getHostAddress();

		File confDir = new File(INTELLIGENCE_CENTER_SERVER_HOME, "conf");
		File configFile = new File(confDir, "hstaxii-server-conf.xml");
		conf.addResource(new Path(configFile.getAbsolutePath()));
		
		int port = conf.getInt("jetty.server.port", 9720);
		String ssl = conf.getBoolean("jetty.server.ssl.use", true) ? "Y" : "N";
		
		param.put("server_name", serverDefaultName);
		param.put("server_url", serverIP);
		param.put("server_port", port);
		param.put("server_type", "A");
		param.put("ssl", ssl);
		
		dao.setServerInfo(param);
	}
	
	public void updateServerInfo(){
		HubAndSpokeTaxiiDAO dao = sqlSession.getMapper(HubAndSpokeTaxiiDAO.class);
		Map<String, Object> param = new HashMap<String, Object>();
		
		File confDir = new File(INTELLIGENCE_CENTER_SERVER_HOME, "conf");
		File configFile = new File(confDir, "hstaxii-server-conf.xml");
		conf.addResource(new Path(configFile.getAbsolutePath()));
		
		int port = conf.getInt("jetty.server.port", 9720);
		String ssl = conf.getBoolean("jetty.server.ssl.use", true) ? "Y" : "N";
		
		param.put("server_port", port);
		param.put("ssl", ssl);
		
		dao.updateServerInfo(param);
	}
}
