package top.wonderheng.chatroom.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.ModelAndView;
import top.wonderheng.chatroom.service.UserService;
import top.wonderheng.chatroom.vo.User;

import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.time.Instant;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.Map;

@Controller
public class UserController {

    @Autowired
    private UserService userService;


    /**
     * 执行注册 成功后登录页面 否则调回注册页面
     */
    @PostMapping("/doregister")
    public ModelAndView register(@RequestParam(value = "username", required = false) String username, @RequestParam(value = "password", required = false) String password, HttpServletResponse response) {
        PrintWriter out = null;
        try {
            response.setContentType("text/html;charset=gb2312");
            out = response.getWriter();
        } catch (IOException e) {
            e.printStackTrace();
        }

        if (registerUser(username) == true) {
            User user1 = new User();
            user1.setUsername(username);
            user1.setPassword(password);
            user1.setCreated_date(UDateToLocalDateTime());
            userService.save(user1);
            //注册成功，重定向登录页面
            out.print("<script language=\"javascript\">alert('注册成功，欢迎使用！');</script>");

            return new ModelAndView("index");
        } else {
            //失败重定向注册页面
            out.print("<script language=\"javascript\">alert('注册失败，请稍后再试！');</script>");

            return new ModelAndView("registration");
        }
    }

    /**
     * 跳转登录页面
     *
     * @return
     */
    @RequestMapping("/tryLogin")
    public ModelAndView login() {
        return new ModelAndView("index");
    }

    /**
     * 跳转注册页面
     *
     * @return
     */
    @RequestMapping("/tryregistration")
    public ModelAndView registration() {
        return new ModelAndView("registration");
    }


    public Boolean registerUser(String username) {
        if (userService.findByUsername(username).isEmpty()) {
            return true;
        } else {
            return false;
        }
    }


    /**
     * 执行登录
     */
    @PostMapping("/dologin")
    public ModelAndView login(@RequestParam(value = "username", required = false) String username, @RequestParam(value = "password", required = false) String password, Map<String, String> map, HttpServletResponse response) {

        User user = userService.findByUsernameAndPassword(username, password);
        PrintWriter out = null;
        try {
            response.setContentType("text/html;charset=gb2312");
            out = response.getWriter();
        } catch (IOException e) {
            e.printStackTrace();
        } finally {
            if (user != null) {
                map.put("username", username);
                //登陆成功，重定向聊天页面
                return new ModelAndView("chat", map);
            } else {
                //失败重定向登录页面
                out.print("<script language=\"javascript\">alert('用户名或密码错误，请重试！');</script>");

                return new ModelAndView("index");
            }
        }
    }

    public LocalDateTime UDateToLocalDateTime() {
        java.util.Date date = new java.util.Date();
        Instant instant = date.toInstant();
        ZoneId zone = ZoneId.systemDefault();
        LocalDateTime localDateTime = LocalDateTime.ofInstant(instant, zone);
        return localDateTime;
    }
}
