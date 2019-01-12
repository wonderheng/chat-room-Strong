package top.wonderheng.chatroom.vo;

import com.google.gson.Gson;

import java.text.DateFormat;
import java.util.Date;
import java.util.Map;

public class Message {

    private String content;

    private Map<String,String> names;

    private Date date=new Date();

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }


    public void setContent(String name,String msg) {
        this.content = name+" "+DateFormat.getDateTimeInstance().format(date) +":<br/> "+msg;
    }

    public Map<String, String> getNames() {
        return names;
    }
    public void setNames(Map<String, String> names) {
        this.names = names;
    }


    public String toJson(){
        return gson.toJson(this);
    }

    private static Gson gson=new Gson();

    public Message(String content, Map<String, String> names) {
        this.content = content;
        this.names = names;
    }

    public Message() {
    }
}
