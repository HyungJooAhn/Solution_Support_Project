package com.seculayer.web.tist;

import java.io.IOException;
import java.net.MalformedURLException;
import java.net.URISyntaxException;
import java.util.ArrayList;
import java.util.Map;

import javax.xml.bind.JAXBException;

import org.apache.ibatis.session.SqlSession;
import org.apache.log4j.Logger;
import org.mitre.taxii.client.HttpClient;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.RequestMapping;
import org.xml.sax.SAXException;

import com.seculayer.web.tist.dao.ThreatInfoDAO;
import com.seculayer.web.tist.stix.STIXGenerator;
import com.seculayer.web.tist.stix.STIXParser;
import com.seculayer.web.tist.taxii.PollClient;


@Controller
@RequestMapping(value = "/tist/")
public class ThreatInfoService {
	
	private STIXGenerator stixGen = new STIXGenerator();
	private STIXParser stixParser = new STIXParser();
	private PollClient taxiiPullClient = new PollClient();
	
	@Autowired private SqlSession sqlSession;
	
	static Logger logger = Logger.getLogger(ThreatInfoService.class);

	@Transactional(rollbackFor=Exception.class)
	public void insert(Map<String, Object> map) {
		ThreatInfoDAO dao = sqlSession.getMapper(ThreatInfoDAO.class);
		
		dao.insertTaxiiServer(map);
	}
	
	@Transactional(rollbackFor=Exception.class)
	public Map<String,Object> select(Map<String,Object> map) {
		ThreatInfoDAO dao = sqlSession.getMapper(ThreatInfoDAO.class);
		Map<String, Object> data = dao.selectTaxiiServer(map);

		return data;
	}
	
	@Transactional(rollbackFor=Exception.class)
	public void update(Map<String, Object> map) {
		ThreatInfoDAO dao = sqlSession.getMapper(ThreatInfoDAO.class);
		dao.updateTaxiiServer(map);
	}

	@Transactional(rollbackFor=Exception.class)
	public void delete(Map<String, Object> map) {
		ThreatInfoDAO dao = sqlSession.getMapper(ThreatInfoDAO.class);
		dao.deleteTaxiiServer(map);
	}
	
	public String genSTIXTpl(Map<String, Object> map) throws SAXException{
		return stixGen.generate(map);
	}
	
	public ArrayList<Object> getSTIXParsing(Map<String, Object> map) throws SAXException{
		return stixParser.stixParsing(map.get("file_cont").toString());
	}
	
	public ArrayList<Object> taxiiSvcPull(Map<String, Object> map) throws MalformedURLException, JAXBException, IOException, URISyntaxException, Exception{
		String collection = map.get("collection").toString();
		
		String url = "";
		if("http".equals(map.get("server_ip").toString().substring(0,4))){
			if((map.get("server_port") == null) || ("".equals(map.get("server_port").toString()))){
				url = map.get("server_ip").toString();	
			}else{
				url = map.get("server_ip").toString() + ":" + map.get("server_port").toString();
			}
		}else{
			if((map.get("server_port") == null) || ("".equals(map.get("server_port").toString()))){
				url = "http://" + map.get("server_ip").toString();				
			}else{
				url = "http://" + map.get("server_ip").toString() + ":" + map.get("server_port").toString();
			}
		}

		String[] prop = {"-u", url , "-username", map.get("username").toString(), "-pass", map.get("password").toString()};
		String service_path = map.get("server_service").toString();
		
		return taxiiPullClient.pullService(prop, collection, service_path);
	}
	
}
