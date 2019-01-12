package top.wonderheng.chatroom.service;

import top.wonderheng.chatroom.vo.ContentVo;
import top.wonderheng.chatroom.vo.Message;
import com.google.gson.Gson;
import org.springframework.stereotype.Component;
import top.wonderheng.chatroom.vo.RandomCar;

import javax.websocket.*;
import javax.websocket.server.ServerEndpoint;
import java.net.URLDecoder;
import java.util.*;
import java.util.concurrent.CopyOnWriteArraySet;

@Component
@ServerEndpoint("/webSocket")
public class WebSocket {

    private Session session;
    private String username;

    private static CopyOnWriteArraySet<WebSocket> webSockets = new CopyOnWriteArraySet<>();
    private static Map<String, String> map = new HashMap<>();
    private static RandomCar randomCar = new RandomCar();

    @OnOpen
    public void onOpen(Session session) {
        this.session = session;
        webSockets.add(this);
        //获取用户名
        String s = session.getQueryString();
        String urlUsername = s.split("=")[1];
        try {
            username = URLDecoder.decode(urlUsername, "UTF-8");
        } catch (Exception e) {
            e.printStackTrace();
        }

        //把SessionID和用户名放进集合里面
        map.put(session.getId(), username);
        System.out.println("有新的连接，总数：" + webSockets.size() + "  sessionId：" + session.getId() + "  " + username);
        String content = "\"" + username + "\"  开着超级酷炫的 \"" + randomCar.getMap() + "\" 进入了聊天室！";
        Message message = new Message(content, map);
        send(message.toJson());
    }

    @OnClose
    public void onClose() {
        webSockets.remove(this);
        map.remove(session.getId());
        System.out.println("有新的断开，总数：" + webSockets.size() + "  sessionId：" + session.getId());
        String content = "\"" + username + "\"  离开了聊天室！";
        Message message = new Message(content, map);
        send(message.toJson());
    }


    private static Gson gson = new Gson();

    @OnMessage
    public void onMessage(String json) {

        ContentVo contentVo = gson.fromJson(json, ContentVo.class);


        if (contentVo.getType() == 1) {
            //广播
            Message message = new Message();
            message.setContent(this.username, contentVo.getMsg());
            message.setNames(map);
            send(message.toJson());
            System.out.println(message.toJson());
        } else {
            //单聊
            Message message = new Message();
            message.setContent(this.username, contentVo.getMsg());
            message.setNames(map);

            String to = contentVo.getTo();
            String tos[] = to.substring(0, to.length() - 1).split("-");
            List<String> lists = Arrays.asList(tos);
            for (WebSocket webSocket : webSockets) {
                if (lists.contains(webSocket.session.getId()) && webSocket.session.getId() != this.session.getId()) {
                    try {
                        webSocket.session.getBasicRemote().sendText(message.toJson());
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
            }
        }

    }

    public void send(String message) {
        for (WebSocket webSocket : webSockets) {
            try {
                webSocket.session.getBasicRemote().sendText(message);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }

}
