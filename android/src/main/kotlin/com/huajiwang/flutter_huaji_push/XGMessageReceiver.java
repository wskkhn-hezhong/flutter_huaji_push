package com.huajiwang.flutter_huaji_push;

import android.content.Context;
import com.tencent.android.tpush.XGPushBaseReceiver;
import com.tencent.android.tpush.XGPushClickedResult;
import com.tencent.android.tpush.XGPushRegisterResult;
import com.tencent.android.tpush.XGPushShowedResult;
import com.tencent.android.tpush.XGPushTextMessage;

import java.util.HashMap;
import java.util.Map;

public class XGMessageReceiver extends XGPushBaseReceiver {
    @Override
    public void onRegisterResult(Context context, int errorCode, XGPushRegisterResult message) {
        if (context == null || message == null) {
            String msg = "TPNS token: null" + " error: context==null||message == null";
            FlutterHuajiPushPlugin.instance.toFlutterMethod(Extras.ON_REGISTERED_DEVICE_TOKEN, msg);
            return;
        }
        if (errorCode == XGPushBaseReceiver.SUCCESS) {
            String token = message.getToken();
            String msg = token;
            FlutterHuajiPushPlugin.instance.toFlutterMethod(Extras.ON_REGISTERED_DONE, msg);
        } else {
            String msg = "TPNS token: " + message.getToken() + " error: " + errorCode;
            FlutterHuajiPushPlugin.instance.toFlutterMethod(Extras.ON_REGISTERED_DEVICE_TOKEN, msg);
        }
    }

    @Override
    public void onUnregisterResult(Context context, int errorCode) {
        if (context == null) {
            String msg = "context == null---->Unregister failure";
            FlutterHuajiPushPlugin.instance.toFlutterMethod(Extras.UN_REGISTERED, msg);
            return;
        }
        String text = "";
        if (errorCode == XGPushBaseReceiver.SUCCESS) {
            String msg = "Unregister successful";
            FlutterHuajiPushPlugin.instance.toFlutterMethod(Extras.UN_REGISTERED, msg);
        } else {
            String msg = "Unregister failure---->code==" + errorCode;
            FlutterHuajiPushPlugin.instance.toFlutterMethod(Extras.UN_REGISTERED, msg);
        }
    }

    @Override
    public void onSetTagResult(Context context, int errorCode, String s) {

    }

    @Override
    public void onDeleteTagResult(Context context, int errorCode, String s) {

    }

    @Override
    public void onSetAccountResult(Context context, int i, String s) {

    }

    @Override
    public void onDeleteAccountResult(Context context, int i, String s) {

    }

    @Override
    public void onSetAttributeResult(Context context, int i, String s) {

    }

    @Override
    public void onDeleteAttributeResult(Context context, int i, String s) {

    }

    @Override
    public void onTextMessage(Context context, XGPushTextMessage message) {
        String content = message.getContent();
        String customContent = message.getCustomContent();
        String title = message.getTitle();
        int pushChannel = message.getPushChannel();
        Map<String, Object> para = new HashMap<>();
        para.put(Extras.TITLE, title);
        para.put(Extras.CONTENT, content);
        para.put(Extras.CUSTOM_MESSAGE, customContent);
        para.put(Extras.PUSH_CHANNEL, pushChannel);
        //交由Flutter自主处理
        FlutterHuajiPushPlugin.instance.toFlutterMethod(Extras.ON_RECEIVE_MESSAGE, para);
    }

    @Override
    public void onNotificationClickedResult(Context context, XGPushClickedResult notifiShowedRlt) {
        if (context == null || notifiShowedRlt == null) {
            Map<String, Object> para = new HashMap<>();
            para.put(Extras.RESULT_CODE, -1);
            para.put(Extras.MESSAGE, "通知栏展示失败----context == null ||  notifiShowedRlt == null");
//            FlutterHuajiPushPlugin.instance.toFlutterMethod(
//                    Extras.TO_FLUTTER_METHOD_NOTIFACTION_SHOW_RESULT, para);
            return;
        }
        String content = notifiShowedRlt.getContent();
        String customContent = notifiShowedRlt.getCustomContent();
        String title = notifiShowedRlt.getTitle();
        int notificationActionType = notifiShowedRlt.getNotificationActionType();
        long msgId = notifiShowedRlt.getMsgId();
        String activityName = notifiShowedRlt.getActivityName();
        long actionType = notifiShowedRlt.getActionType();

        Map<String, Object> para = new HashMap<>();
        para.put(Extras.TITLE, title);
        para.put(Extras.CONTENT, content);
        para.put(Extras.CUSTOM_MESSAGE, customContent);
        para.put(Extras.MSG_ID, msgId);
        para.put(Extras.NOTIFACTION_ACTION_TYPE, notificationActionType);
        para.put(Extras.ACTIVITY_NAME, activityName);
        para.put(Extras.ACTION_TYPE, actionType);
        //交由Flutter自主处理
        FlutterHuajiPushPlugin.instance.toFlutterMethod(Extras.XG_PUSH_CLICK_ACTION, para);
    }

    @Override
    public void onNotificationShowedResult(Context context, XGPushShowedResult message) {
        if (context == null || message == null) {
            Map<String, Object> para = new HashMap<>();
            para.put(Extras.RESULT_CODE, -1);
            para.put(Extras.MESSAGE, "点击通知失败----context == null ||  XGPushClickedResult == null");
//            FlutterHuajiPushPlugin.instance.toFlutterMethod(
//                    Extras.TO_FLUTTER_METHOD_NOTIFACTION_SHOW_RESULT, para);
            return;
        }
        String content = message.getContent();
        String customContent = message.getCustomContent();
        int notifactionId = message.getNotifactionId();
        String title = message.getTitle();
        long msgId = message.getMsgId();
        String activityPath = message.getActivity();
        int pushChannel = message.getPushChannel();
        int notificationActionType = message.getNotificationActionType();
        Map<String, Object> para = new HashMap<>();
        para.put(Extras.CONTENT, content);
        para.put(Extras.CUSTOM_MESSAGE, customContent);
        para.put(Extras.TITLE, title);
        para.put(Extras.PUSH_CHANNEL, pushChannel);
        para.put(Extras.NOTIFACTION_ID, notifactionId);
        para.put(Extras.MSG_ID, msgId);
        para.put(Extras.ACTIVITY, activityPath);
        para.put(Extras.NOTIFACTION_ACTION_TYPE, notificationActionType);
        //交由Flutter自主处理
        FlutterHuajiPushPlugin.instance.toFlutterMethod(Extras.ON_RECEIVE_NOTIFICATION_RESPONSE, para);
    }
}
