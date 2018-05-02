<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="weaver.general.Util,weaver.hrm.common.*,weaver.conn.*,weaver.systeminfo.*" %>
<%@ page import="weaver.hrm.attendance.domain.*,weaver.hrm.User"%>
<!-- Added by wcd 2015-06-25[自定义请假单] -->
<jsp:useBean id="strUtil" class="weaver.common.StringUtil" scope="page" />
<jsp:useBean id="dateUtil" class="weaver.common.DateUtil" scope="page" />
<jsp:useBean id="rs" class="weaver.conn.RecordSet" scope="page" />
<%
	User user = (User)request.getSession(true).getAttribute("weaver_user@bean");
	int nodetype = strUtil.parseToInt(request.getParameter("nodetype"), 0);
	int workflowid = strUtil.parseToInt(request.getParameter("workflowid"), 0);
	int formid = strUtil.parseToInt(request.getParameter("formid"));
	int userid = strUtil.parseToInt(request.getParameter("userid"));
	String creater = strUtil.vString(request.getParameter("creater"), String.valueOf(userid));
	int requestId = Util.getIntValue(request.getParameter("requestid"));
	int currentnodetype = Util.getIntValue((String)session.getAttribute(user.getUID()+"_"+requestId+"currentnodetype"),0);
	String currentdate = strUtil.vString(request.getParameter("currentdate"), dateUtil.getCurrentDate());
	String f_weaver_belongto_userid = strUtil.vString(request.getParameter("f_weaver_belongto_userid"));
	String f_weaver_belongto_usertype = strUtil.vString(request.getParameter("f_weaver_belongto_usertype"));
	
	String resourceId = "";//申请人
	String bdksj = "";//补打卡日期
	String wdksj = "";//补打卡时间段(0上午 1下午 2全天)
	String wdksj1 = "";//未打卡时间
	rs.executeSql("select id,fieldname from workflow_billfield where billid = " + formid + " ");
	while(rs.next()){
		String fieldnameStrTemp = Util.null2String(rs.getString("fieldname")); 
		if("resourceId".equals(fieldnameStrTemp))
			resourceId = "field" + Util.null2String(rs.getString("id"));
		if("bdksj".equals(fieldnameStrTemp))
			bdksj = "field" + Util.null2String(rs.getString("id"));
		if("wdksj".equals(fieldnameStrTemp))
			wdksj = "field" + Util.null2String(rs.getString("id"));
		if("wdksj1".equals(fieldnameStrTemp))
			wdksj1 = "field" + Util.null2String(rs.getString("id"));
	}
%>

<script language="javascript">
var nodetype = "<%=nodetype%>";
var workflowid = "<%=workflowid%>";
var formid = "<%=formid%>";
var userid = "<%=userid%>";
var requestId = "<%=requestId%>";
var currentnodetype = "<%=currentnodetype%>";
var _field_resourceId = "<%=resourceId%>";
var _field_bdksj = "<%=bdksj%>";
var _field_wdksj = "<%=wdksj%>";
var _field_wdksj1 = "<%=wdksj1%>";
var f_weaver_belongto_userid = "<%=f_weaver_belongto_userid%>";
var f_weaver_belongto_usertype = "<%=f_weaver_belongto_usertype%>";

function ajaxInit(){
	var ajax=false;
	try {
		ajax = new ActiveXObject("Msxml2.XMLHTTP");
	} catch (e) {
		try {
			ajax = new ActiveXObject("Microsoft.XMLHTTP");
		} catch (E) {
			ajax = false;
		}
	}
	if (!ajax && typeof XMLHttpRequest!='undefined') {
		ajax = new XMLHttpRequest();
	}
	return ajax;
}

jQuery(document).ready(function(){
	if(currentnodetype == 0) {
		newCheckCustomize();
	}
});
	
function bindEvent(func){
	checkCustomize = func;
}
	
function newCheckCustomize() {
	bindEvent(function(){
	    var returnStr = true;
	    returnStr = checkInfo();
	    if(returnStr){
	    	returnStr = checkTime();
	    }
		return returnStr;
	});
}

function checkInfo(){
 		var begindate = jQuery("#"+_field_bdksj).val();
	    var begintime = jQuery("#"+_field_wdksj).val();
	    var resourceId = jQuery("#"+_field_resourceId).val();
	    if(begindate !="" && begintime != "") {
	    	var begindateYear = begindate.substring(0,4)*1;
	    	var begindateMonth = begindate.substring(5,7)*1;
	    	var today = new Date();
	        var year = today.getFullYear();
	        var month = today.getMonth() + 1;
			var date = today.getDate();
			var monthStr = month;
			var hour = today.getHours();
			var minutes = today.getMinutes();
			if(month < 10) monthStr = "0"+monthStr;
			if(date < 10) date = "0"+date;
			if(hour < 10) hour = "0"+hour;
			if(minutes < 10) minutes = "0"+minutes;
			var currentdate = year+"-"+monthStr+"-"+date;
			var currenttime = hour+":"+minutes;
		//	if(begindateYear == year && begindateMonth == month) {
				var ajax=ajaxInit();
				ajax.open("POST", "/proj/process/GetWorkDays.jsp", false);
				ajax.setRequestHeader("Content-Type","application/x-www-form-urlencoded");
				ajax.send("begindate="+begindate+"&begintime="+currenttime+"&enddate="+currentdate+"&endtime="+currenttime);
	      		try{
	      			var workdays=trim(ajax.responseText)*1;
					//alert("workdays==" + workdays);
					if(workdays < 0) {
						alert("不允许提前补打卡!");
						return false;
					} 
					/*else if(workdays > 2){
						alert("不能补2个工作日之前的打卡!");
						return false;
					}*/
	      		}catch(e){
	    			alert("补打卡日期判断异常!请关闭后重试!");
	    			return false;
	    		}

				ajax.open("POST", "/workflow/request/BillBoHaiLeaveXMLHTTP.jsp", false);
				ajax.setRequestHeader("Content-Type","application/x-www-form-urlencoded");
				ajax.send("operation=getBuDaKaInOneMonth&resourceID="+resourceId+"&fromDate="+begindate);
				try{
					var oneMonthTimes=trim(ajax.responseText);
					//alert("oneMonthTimes==" + oneMonthTimes);
					if(oneMonthTimes == "3") {
						alert("当前月已补三次!不允许提交申请!");
						return false;
					}
				}catch(e){
					alert("每人每月不能超过3次判断异常!请关闭后重试!");
					return false;
				}
			//} else {
			//	alert("补打卡必须当月");
			//	return false;
		//	}
	    }
	    return true;
}
//上午字段选择时间 最早不能早于9.30 。下午字段选择时间 不能晚于16点 
function checkTime(){
	  var str = true;
	  var begintimeSelect = jQuery("#"+_field_wdksj).val();//(0上午 1下午)
	  var begintime = jQuery("#"+_field_wdksj1).val();
	//  alert("begintimeSelect="+begintimeSelect+"||begintime="+begintime);
	  if(begintimeSelect!="" && begintime != ""){
	  	if(begintimeSelect == 0){
	  		if(begintime < "09:30" || begintime > "12:30"){
	  			//alert("上午补打卡时间不能早于09:30！");
				alert("上午补打卡时间为9:30到12:30！请修改后提交!");
	  			str = false;
	  		}
	  	}
	  if(begintimeSelect == 1){
	  		if(begintime > "16:00" || begintime < "13:00" ){
	  			//alert("上午补打卡时间不能晚于16:00！");
				alert("下午补打卡时间为13:00到16:00！请修改后提交!");
	  			str = false;
	  		}
	  	}
	  }
	  return str;
}
</script>