package com.seculayer.web.login.dao;

import java.util.Map;

public interface LoginDAO {
	public Map<String,Object> detailUserInfo(String userId);
	public void updqteUserLastConnDt(String userId);
}
