package com.seculayer.web.employee;

import java.util.Map;

import org.apache.ibatis.session.SqlSession;
import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.RequestMapping;

import com.seculayer.web.employee.dao.ReservationDAO;


@Controller
@RequestMapping(value = "/reservation/")
public class ReservationService {
	

	@Autowired private SqlSession sqlSession;
	
	static Logger logger = Logger.getLogger(ReservationService.class);

	@Transactional(rollbackFor=Exception.class)
	public void insert(Map<String, Object> map) {
		ReservationDAO dao = sqlSession.getMapper(ReservationDAO.class);
		
		dao.insertReservation(map);
	}
	
	@Transactional(rollbackFor=Exception.class)
	public Map<String,Object> select(Map<String,Object> map) {
		ReservationDAO dao = sqlSession.getMapper(ReservationDAO.class);
		Map<String, Object> data = dao.selectCalendarDataId(map);

		return data;
	}
	
	@Transactional(rollbackFor=Exception.class)
	public void update(Map<String, Object> map) {
		ReservationDAO dao = sqlSession.getMapper(ReservationDAO.class);
		dao.updateReservation(map);
	}

	@Transactional(rollbackFor=Exception.class)
	public void delete(Map<String, Object> map) {
		ReservationDAO dao = sqlSession.getMapper(ReservationDAO.class);
		dao.deleteReservation(map);
	}
	
}
