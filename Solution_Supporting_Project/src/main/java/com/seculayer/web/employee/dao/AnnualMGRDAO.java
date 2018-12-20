package com.seculayer.web.employee.dao;

import java.util.List;
import java.util.Map;

public interface AnnualMGRDAO {
	
	public List<Map<String, Object>> selectAnnualList(Map<String,Object> map);
	public List<Map<String, Object>> selectAnnualListWeekly(Map<String,Object> map);
	public List<Map<String, Object>> selectAnnualListByID(Map<String,Object> map);
	public void insertAnnual(Map<String,Object> map);
	
	public void updateAnnualList(Map<String,Object> map);
	public void deleteAnnualList(Map<String,Object> map);
}
