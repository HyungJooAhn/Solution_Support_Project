package com.seculayer.web.tist.dao;

import java.util.List;
import java.util.Map;

public interface ThreatInfoDAO {
	
	public int selectServerListCount(Map<String,Object> map);
	public List<Map<String, Object>> selectServerList(Map<String,Object> map);
	
	public int checkServerIP(Map<String,Object> map);
	public int checkServerID(Map<String,Object> map);
	public void insertTaxiiServer(Map<String,Object> map);

	public Map<String, Object> selectTaxiiServer(Map<String,Object> map);
	public void updateTaxiiServer(Map<String,Object> map);
	public void deleteTaxiiServer(Map<String,Object> map);
}
