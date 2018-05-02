<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="weaver.hrm.attendance.domain.*,weaver.general.Util"%>
<%@ include file="/systeminfo/init_wev8.jsp" %>
<!-- Added by wcd 2015-09-10[加班流程] -->
<jsp:useBean id="strUtil" class="weaver.common.StringUtil" scope="page" />
<jsp:useBean id="dateUtil" class="weaver.common.DateUtil" scope="page" />
<jsp:useBean id="attProcSetManager" class="weaver.hrm.attendance.manager.HrmAttProcSetManager" scope="page" />
<%
	int nodetype = strUtil.parseToInt(request.getParameter("nodetype"), 0);
	int requestId = Util.getIntValue(request.getParameter("requestid"));
	int currentnodetype = Util.getIntValue((String)session.getAttribute(user.getUID()+"_"+requestId+"currentnodetype"),0);
	int workflowid = strUtil.parseToInt(request.getParameter("workflowid"), 0);
	int formid = strUtil.parseToInt(request.getParameter("formid"));
	int userid = strUtil.parseToInt(request.getParameter("userid"));
	String creater = strUtil.vString(request.getParameter("creater"), String.valueOf(userid));
	String[] fieldList = attProcSetManager.getFieldList(3, workflowid, formid);
	String currentdate = strUtil.vString(request.getParameter("currentdate"), dateUtil.getCurrentDate());
	String f_weaver_belongto_userid = strUtil.vString(request.getParameter("f_weaver_belongto_userid"));
	String f_weaver_belongto_usertype = strUtil.vString(request.getParameter("f_weaver_belongto_usertype"));
	if(fieldList.length == 0) return;
%>
<script language="javascript">
	var requestid = jQuery("input[name='requestid']").val();
	var currentnodeid = jQuery("input[name='nodeid']").val();
	var workflowid = "<%=workflowid%>";
	var currentnodetype = "<%=currentnodetype%>";
	var formid = "<%=formid%>";
	var creater = "<%=creater%>";
	var _field_resourceId = "<%=fieldList[0]%>";
	var _field_fromdate = "<%=fieldList[1]%>";
	var _field_fromtime = "<%=fieldList[2]%>";
	var _field_tilldate = "<%=fieldList[3]%>";
	var _field_tilltime = "<%=fieldList[4]%>";
	var _field_overtimeDays = "<%=fieldList[5]%>";
	var _field_departmentId = "<%=fieldList[6]%>";
	var _field_otype = "<%=fieldList[7]%>";
	var f_weaver_belongto_userid = "<%=f_weaver_belongto_userid%>";
	var f_weaver_belongto_usertype = "<%=f_weaver_belongto_usertype%>";
	
	function onShowTimeCallBack(id) {
		var fieldid = id.split("_")[0];
		var rowindex = id.split("_")[1];
		wfbrowvaluechange_fna(null, fieldid, rowindex);
	}
	
	function wfbrowvaluechange_fna(obj, fieldid, rowindex) {
		fieldid = "field"+fieldid;
		if(_field_fromdate==fieldid || _field_fromtime==fieldid || _field_tilldate==fieldid || _field_tilltime==fieldid){
			var fromdate = jQuery("#"+_field_fromdate).val();
			var fromtime = jQuery("#"+_field_fromtime).val();
			var tilldate = jQuery("#"+_field_tilldate).val();
			var tilltime = jQuery("#"+_field_tilltime).val();
			var overtimeDaysObj = jQuery("#"+_field_overtimeDays);
			var overtimeDaysType = overtimeDaysObj.attr("type");
			if(overtimeDaysObj.attr("readonly") != true) overtimeDaysObj.attr("readonly","readonly");
		
			setValue(fromdate, fromtime, tilldate, tilltime, overtimeDaysObj, overtimeDaysType, rowindex);
		}
	}

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

	function setValue(fromdate, fromtime, tilldate, tilltime, overtimeDaysObj, overtimeDaysType, rowindex){
		if(fromdate != '' && fromtime!='' && tilldate!='' && tilltime!=''){
			var ajax=ajaxInit();
			ajax.open("POST", "/workflow/request/BillBoHaiLeaveXMLHTTP.jsp", true);
			ajax.setRequestHeader("Content-Type","application/x-www-form-urlencoded");
			ajax.send("operation=getLeaveDays&f_weaver_belongto_userid="+f_weaver_belongto_userid+"&worktime=false&f_weaver_belongto_usertype="+f_weaver_belongto_usertype+"&fromDate="+fromdate+"&fromTime="+fromtime+"&toDate="+tilldate+"&toTime="+tilltime+"&resourceId="+creater);
			ajax.onreadystatechange = function() {
				if (ajax.readyState == 4 && ajax.status == 200) {
					try {
						var result = trim(ajax.responseText);
						overtimeDaysObj.val(result);
						if(overtimeDaysType == 'hidden') jQuery("#"+_field_overtimeDays+"span").html(result);
					} catch(e) {
						overtimeDaysObj.val("0.0");
						if(overtimeDaysType == 'hidden') jQuery("#"+_field_overtimeDays+"span").html('0.0');
					}
				}
			}
		}
	}

	checkCustomize = function() {
		var flag = true;
		var resourceId = jQuery("#field6008").val();//加班人
		var beginDate = jQuery("#field6012").val();//实际加班开始日期
        var beginTime = jQuery("#field6013").val();//实际加班开始时间
        var endDate = jQuery("#field6014").val();//实际加班结束日期
        var endTime = jQuery("#field6015").val();//实际加班结束时间
        var overWorkDays = jQuery("#field6016").val()*1;//实际加班天数
		var overWorkType = jQuery("#field6020").val();//加班类型
        //alert("overWorkDays="+overWorkDays); 
        //alert(beginDate+"||"+beginTime+"||"+endDate+"||"+endTime+"||"+overWorkDays);
		//请假结束日期大于请假开始日期
        if(currentnodetype == 0){
            var beginD = new Date((beginDate + " " + beginTime + ":00").replace(/-/g,"\/"));
        	var endD = new Date((endDate + " " + endTime + ":00").replace(/-/g,"\/"));
        	//alert("beginD="+beginD+"||endD="+endD);
        	if(beginD > endD) {
        		alert("结束日期早于开始日期，流程不允许提交！");
        		return  false;
        	}
        }
		if((workflowid == "114" || currentnodetype > 0) ||(workflowid == "128" && currentnodetype == 0) ){
			return true;
		}else if (workflowid == "46" || (workflowid == "128" && currentnodetype > 0)){
	        if(beginDate !="" && beginTime != "" && endDate != "" && endTime != "" && overWorkDays != "") {
	       // alert(beginDate+"||"+beginTime+"||"+endDate+"||"+endTime+"||"+overWorkDays);
	        	try{
	            	var today = new Date();//系统时间
	                var year = today.getFullYear();       //年
	                var month = today.getMonth() + 1;     //月
	        		if(month < 10) month = "0"+month;
	                var day = today.getDate();            //日
					if(day < 10) day = "0"+day;
	                var todayStr = year+"-"+month+"-"+day;
	            	var date1 = new Date(beginDate.replace(/\-/g, "/") + " " + beginTime + ":00");//开始时间
	            	var date2 = new Date(endDate.replace(/\-/g, "/") + " " + endTime + ":00");//结束时间
	            	var hours = parseInt((date2.getTime() - date1.getTime()) / 1000 / 60 / 60);
	            	//alert("hours===" + hours);
	            	
	            	var txhour = (getTXZSInfo(resourceId,beginDate,workflowid))*1*24;	
	            	
	            	//alert("txhour===" + txhour);
	            	if((hours + txhour) > 36) {
		            	//alert("txhour===" + txhour);
		            	window.top.Dialog.alert("当月总加班时长不得超过36小时!");
		            	return false;
	            	}

					if(beginDate != endDate) {
						window.top.Dialog.alert("加班不能跨天!");
						return false;
					}
					if(workflowid == "46" && currentnodetype == 0){
						if((beginDate <= todayStr) || (endDate <= todayStr)) {
							window.top.Dialog.alert("加班只能提前一天!");
							return false;
						}
					}
	        		
	        		if(overWorkType == "0") {
		        		if(beginTime < "19:00") {
		        			window.top.Dialog.alert("实际加班开始时间必须是19点后!");
			        		return false;
		        		}
	        		}
	                
	        		/*if(hours < 2) {
	        			window.top.Dialog.alert("实际加班时间至少两小时!");
		        		return false;
	        		}*/
	        		if(hours < 1) {
	        		//alert("in");
	        			window.top.Dialog.alert("实际加班时间至少1小时!");
		        		return false;
	        		}
	        		return true;
	            } catch(e) {
	            	alert(e.message);
	            	return false
	            }
	        } else {
	        	//alert("1111111");
	        	return false;
	        }
	        return true;
		}
	};
	
	/*获取根据实际加班开始日期对应当月的总计加班时长*/
	function getTXZSInfo(resourceId,currentDate,workflowid) {
		var param = "";
		if(workflowid == "128"){//紧急加班
			param = "0";
		}
		var ajax = ajaxInit();
		ajax.open("POST", "/workflow/request/BillBoHaiLeaveXMLHTTP.jsp", false);
	    ajax.setRequestHeader("Content-Type","application/x-www-form-urlencoded");
	    ajax.send("operation=getTXZSInfo&resourceId="+resourceId+"&currentDate="+currentDate+"&param="+param);
	    try{
		  	var date = trim(ajax.responseText);
		  	//alert(date);
			return date;
	    }catch(e){
			//alert(e.message);
			return "100";
		}
	}
</script>