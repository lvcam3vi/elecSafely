//
//  ElecAPIHeader.h
//  ElecSafely
//
//  Created by Tianfu on 01/02/2018.
//  Copyright © 2018 Tianfu. All rights reserved.
//

#ifndef ElecAPIHeader_h
#define ElecAPIHeader_h

/*设备查询*/
#define FrigateAPI_Query @"http://www.frigate-iot.com/API/Query.php"
/*设备录入*/
#define FrigateAPI_BindApp @"http://www.frigate-iot.com/login/app/login_bind.php"
/*设备复位*/
#define FrigateAPI_Reset @"http://www.frigate-iot.com/API/Reset.php"
/*设备实时信息*/
#define FrigateAPI_DeviceStatus @"http://www.frigate-iot.com/MonitoringCentre/Data/DevStatus.php"
/*获取设备最近7天设备查询数据信息*/
#define FrigateAPI_DeviceHistory @"http://www.frigate-iot.com/MonitoringCentre/Data/DevDataHistory.php"
/*警报列表*/
#define FrigateAPI_AlarmList @"http://www.frigate-iot.com/MonitoringCentre/Log/Data/Log-Data.php"
/*设备列表*/
#define FrigateAPI_DeviceList @"http://www.frigate-iot.com/MonitoringCentre/DList/Data/DList-Data.php"
/*客户分组*/
#define FrigateAPI_CustomerGroup @"http://www.frigate-iot.com/MonitoringCentre/Data/Pop-LoadGroup.php?CustomerID=%@"
/*客户名称*/
#define FrigateAPI_CustomerList @"http://www.frigate-iot.com/MonitoringCentre/Data/SelectCustomerData.php"

#define FrigateAPI_Login_Check @"http://www.frigate-iot.com/data/login_chk.php"
/*热点问题的url*/
#define FrigateAPI_Help_AnswerForAsk @"http://www.frigate-iot.com/MonitoringCentre/MsgCenter/HotCareList.php"
/*资讯列表*/
#define FrigateAPI_Help_InformationList @"http://www.frigate-iot.com/MonitoringCentre/MsgCenter/InformationList.php"
/*意见反馈的url*/
#define FrigateAPI_SubmitAsk @"http://www.frigate-iot.com/MonitoringCentre/MsgCenter/SubmitAsk.php"

/*修改密码*/
#define FrigateAPI_ChangePW @"http://www.frigate-iot.com/MonitoringCentre/Data/ChangePW.php"

/*设备注册*/
#define FrigateAPI_Register @"http://www.frigate-iot.com/API/Register.php"

/*用户注册*/
#define FrigateAPI_UserInfoRegister @"http://www.frigate-iot.com/API/CreateUser.php"

/*公告列表*/
#define FrigateAPI_loadNotice @"http://www.frigate-iot.com/MonitoringCentre/Data/loadNewNotice.php"

/*公告内容*/
#define FrigateAPI_noticeContent(noticeID) ([NSString stringWithFormat:@"http://www.frigate-iot.com/MonitoringCentre/Data/loadNoticeContent.php?ID=%@",noticeID])

#endif /* ElecAPIHeader_h */
