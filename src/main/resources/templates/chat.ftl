<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/html">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="Access-Control-Allow-Origin" content="*">
    <title>时话时说</title>


    <link rel="stylesheet" href="/css/bootstrap.css"/>
    <link rel="stylesheet" href="/css/font-awesome.min.css"/>
    <link rel="stylesheet" href="/css/build.css"/>
    <link rel="stylesheet" type="text/css" href="/css/qq.css"/>

</head>
<body>

<div class="qqBox">
    <div class="context">
        <div class="conLeft">
            <ul id="userList">

            </ul>
        </div>
        <div class="conRight">
            <div class="Righthead">
                <div class="headName">${username}</div>
            </div>
            <div class="RightCont">
                <ul class="newsList" id="message">

                </ul>
            </div>
            <div class="RightMiddle">
                <div class="file">
                    <img src="/img/file.jpg" height="30px" width="30px" onclick="fileSelect()">
                    <form id="form_photo" method="post" enctype="multipart/form-data"
                          style="width:auto;">
                        <input type="file" name="filename" id="filename" onchange="fileSelected();"
                               style="display:none;">
                        <!-- <button id="fasongPhoto" name="fasongPhoto" class="sendBtn" type="submit"
                        style="border-radius: 5px"></button> -->
                    </form>
                </div>
            </div>
            <div class="RightFoot">


                    <textarea id="dope"
                              style="width: 100%;height: 100%; border: none;outline: none;padding:20px 0 0 3%;" name=""
                              rows="" cols=""></textarea>
                <button id="fasong" class="sendBtn" onclick="send()" style="border-radius: 5px">发送</button>
            </div>
        </div>
    </div>
</div>


<script src="/js/jquery_min.js"></script>
<script src="https://cdn.bootcss.com/jquery.form/4.2.2/jquery.form.min.js"></script>
<script type="text/javascript">
    var webSocket = null;

    //判断当前浏览器是否支持WebSocket
    if ('WebSocket' in window) {
        webSocket = new WebSocket('ws://39.107.67.167:8090/webSocket?username=' + '${username}');
    } else {
        alert("当前浏览器不支持WebSocket");
    }

    //连接发生错误的回调方法
    webSocket.onerror = function () {
        setMessageInnerHTML("WebSocket连接发生错误！");
    }

    webSocket.onopen = function () {
        setMessageInnerHTML("WebSocket连接成功！")
    }

    webSocket.onmessage = function (event) {

        $("#userList").html("");
        eval("var msg=" + event.data + ";");

        if (undefined != msg.content)
            setMessageInnerHTML(msg.content);

        if (undefined != msg.names) {
            $.each(msg.names, function (key, value) {
                var htmlstr = '<li>'
                        + '<div class="checkbox checkbox-success checkbox-inline">'
                        + '<input type="checkbox" class="styled" id="' + key + '" value="' + key + '" checked>'
                        + '<label for="' + key + '"></label>'
                        + '</div>'
                        + '<div class="liLeft"><img src="/img/robot2.jpg"/></div>'
                        + '<div class="liRight">'
                        + '<span class="intername">' + value + '</span>'
                        + '</div>'
                        + '</li>'

                $("#userList").append(htmlstr);
            })
        }
    }

    webSocket.onclose = function () {
        setMessageInnerHTML("WebSocket连接关闭");
    }

    window.onbeforeunload = function () {
        closeWebSocket();
    }

    function closeWebSocket() {
        webSocket.close();
    }

    //文件上传
    function fileSelect() {
        document.getElementById("filename").click();
    }

    function fileSelected() {
        // 文件选择后触发此函数
        var filenames = document.getElementById("filename");
        var len = filenames.files.length;
        var temp;
        for (var i = 0; i < len; i++) {
            temp = filenames.files[i].name;
            $("#dope").val("是否发送图片：" + temp);
        }
    }


    //表单提交,会把所有有name属性的值提交到后台
    function getJson(onSuccess) {
        var form = new FormData(document.getElementById("form_photo"));

        $.ajax({
            "async": true,
            "crossDomain": true,
            url: "http://39.107.67.167:8088/api/upload",
            type: "post",
            mimeType: "multipart/form-data",
            data: form,
            headers: {
                "cache-control": "no-cache",
            },
            processData: false,
            contentType: false,
            success: function (data) {
                string = JSON.parse(data);
                console.log(string);
                //获取发送方图片url
                onSuccess(string.data);
            },
            error: function (e) {
                alert("文件过大！请重试");
            }
        });

    }

    function send() {
        var time = new Date().toLocaleString();
        var message = $("#dope").val();
        $("#dope").val("");
        //发送图片
        if (message.search("是否发送图片：") == 0) {
            //发送图片
            // $("#fasongPhoto").submit();
            var htmlstr = '<li><div class="answerHead"><img src="/img/2.png"></div><div class="answers">'
                    + '[本人]' + '   ' + time + '<br/>' + '<img id="jsonImg">' + '</div></li>';
            //获取接收方图片url
            getJson(function(re){
                webSocketSend(htmlstr,message,re);
            });

        } else {

            //发送消息
            var htmlstr = '<li><div class="answerHead"><img src="/img/2.png"></div><div class="answers">'
                    + '[本人]' + '   ' + time + '<br/>' + message + '</div></li>';
            webSocketSend(htmlstr,message,"");
        }
    };

    function webSocketSend(htmlstr,message,re){
        $("#message").append(htmlstr);
        var ss = $("#userList :checked");
        var to = "";
        $.each(ss, function (key, value) {
            to += value.getAttribute("value") + "-";
        })
        console.info(to);

        if (ss.size() == 0) {
            var obj = {
                msg: message,
                type: 1
            }
        } else {
            var obj = {
                to: to,
                msg: message,
                type: 2
            }
        }
        var msg = JSON.stringify(obj);
        webSocket.send(msg);
        //如果还是不行 就用延时执行函数 setTimeout 把注释放掉
        // setTimeout(function(){
        //     if(re){
        //     $("#jsonImg").attr("src", string.data);
        //     loadDiv(re);
        // }
        // },3000)

        if(re){
            $("#jsonImg").attr("src", string.data);
            // loadDiv(re);
        }

    }


    //回车键发送消息
    $(document).keypress(function (e) {

        if ((e.keyCode || e.which) == 13) {
            $("#fasong").click();
        }

    });

    //局部刷新div
    function loadDiv(sJ) {
        $("#delayImgPer").html('<img src="'+sJ+'" class="delayImg" >');
    }

    //将消息显示在网页上
    function setMessageInnerHTML(innerHTML) {

        if (innerHTML.indexOf("是否发送图片：") != -1) {
            var subStr = innerHTML.substring(0, innerHTML.indexOf("是否发送图片："));
            var msg = '<li>'
                    + '<div class="nesHead">'
                    + '<img src="/img/robot.jpg">'
                    + ' </div>'
                    + '<div class="news">'
                    + subStr
                    + '<img class="delayImg" src="/img/404.jpg">'
                    + '</div>'
                    + '</li>';
        } else {
            var msg = '<li>'
                    + '<div class="nesHead">'
                    + '<img src="/img/robot.jpg">'
                    + ' </div>'
                    + '<div class="news">'
                    + innerHTML
                    + '</div>'
                    + '</li>';
        }
        $("#message").append(msg);

    }
</script>

</body>
</html>