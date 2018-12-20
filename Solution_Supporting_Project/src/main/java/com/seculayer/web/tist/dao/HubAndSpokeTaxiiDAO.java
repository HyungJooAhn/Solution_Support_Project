package com.seculayer.web.tist.dao;

import java.util.List;
import java.util.Map;

public interface HubAndSpokeTaxiiDAO {
	
	public int checkServerInfo();
	public Map<String, Object> selectServerInfo();
	public List<Map<String, Object>> selectServerInfoByType(Map<String, Object> param);
	public List<Map<String, Object>> selectThreatServerInfo(Map<String, Object> param);
	public void updateThreatServerInfo(Map<String, Object> param);
	public void deleteThreatServerInfo(Map<String, Object> param);
	public int setServerInfo(Map<String, Object> param);
	public int updateServerInfo(Map<String, Object> param);
	
	public int insertThreatSharingServer(Map<String, Object> param);
}
