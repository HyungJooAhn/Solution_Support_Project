package com.seculayer.web.employee.dao;

import java.util.List;
import java.util.Map;

public interface ReservationDAO {
	
	public List<Map<String, Object>> selectCalendarData(Map<String,Object> map);
	public void insertReservation(Map<String,Object> map);
	public Map<String, Object> selectCalendarDataId(Map<String,Object>map);
	public void updateReservation(Map<String,Object> map);
	public void deleteReservation(Map<String,Object> map);
}
