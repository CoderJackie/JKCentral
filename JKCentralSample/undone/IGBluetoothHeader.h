//
//  IGBluetoothHeader.h
//  BabyBluetoothAppDemo
//
//  Created by xujiaqi on 2018/1/22.
//  Copyright © 2018年 CoderJackie. All rights reserved.
//

#ifndef IGBluetoothHeader_h
#define IGBluetoothHeader_h

//包长相关的宏
#define MAX_PACK_LEN 2048
#define MAX_SEND_LEN 1024
#define MAX_SINGLE_PACKET_LEN 20

/* 新协议 命令字 begin */
/* 请求和应答协议版本命令字*/
#define REQUEST_PROTOCOL_VERSION                0X4001
#define RESPONSE_PROTOCOL_VERSION               0X0001

#define REQUEST_BIND_BLE_DEVICE                 0X4002      // 请求绑定设备
#define RESPONSE_BIND_BLE_DEVICE                0X0002      // 应答

#define REQUEST_SYNC_DATA                       0X4006      // 请求同步数据
#define RESPONSE_SYNC_DATA                      0X0006      // 应答

#define REQUEST_KEY_DATA                        0X4008      // 请求数据
#define RESPONSE_KEY_DATA                       0X0008      // 应答

#define REQUEST_DELETE_DATA                     0X4010      // 请求删除数据
#define RESPONSE_DELETE_DATA                    0X0010      // 应答

#define REQUEST_UPGRADE_FIREWARE                0X4012      // 请求升级固件
#define RESPONSE_UPGRADE_FIREWARE               0X0012      // 应答

#define REQUEST_GET_DATA_COMMAND                0X4014      // 请求升级固件
#define RESPONSE_GET_DATA_COMMAND               0X0014      // 应答

#define BLE_PROTOCOL_END_FLAG                   0x004c      //结束位
/* 新协议 命令字 end */

/* 协议类型 */
#define PROTOCOL_TYPE_UPGRADE                   0x10        // 升级协议
#define PROTOCOL_TYPE_BUSINESS                  0x00        // 业务协议
#define PROTOCOL_TYPE_BIND                      0x02        // 绑定协议

//新的蓝牙协议包数据结构
typedef struct
{
    uint8_t         startflag;                  //起始标志      0XF2
    uint8_t         protocol_type;              //协议类型  升级协议:0x10 业务协议:0x00 绑定协议:0x02
    uint8_t         protocol_version;           //协议版本号
    uint8_t         reserved;                   //保留字节
    uint8_t         time[6];                    //协议时间  年以2010为基数往上累加
    uint8_t         timezone;                   //时区
    UInt16          frame_control;              //操作命令字
    uint16_t        body_length;                //数据长度
} Ble_Protocol_Head_T;

typedef struct{
    Ble_Protocol_Head_T*   head;
    uint8_t                 *body;              //包体
    uint16_t                 packet_fcs;        //FCS校验
}Ble_Protocol_Packet_New;

#endif /* IGBluetoothHeader_h */
