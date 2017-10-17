use iron::prelude::*;
use iron_sessionstorage::traits::SessionRequestExt;

use common::http::*;
use common::utils::*;
use services::user::*;

pub fn render_user(req: &mut Request) -> IronResult<Response> {

    let params = get_router_params(req);
    let username = params.find("username").unwrap();

    let user_wrapper = get_user(username);

    if user_wrapper.is_none() {

        redirect_to("/not-found")
    } else {

        let is_login = is_login(req);
        let mut data = ViewData::new(req);
        let user = user_wrapper.unwrap();

        if is_login {

            let session = get_session_obj(req);
            let is_user_self;

            if session["username"].as_str().unwrap() == username {  // 访问用户自己

                is_user_self = true;
            } else {

                is_user_self = false;
            }

            data.insert("is_user_self", json!(is_user_self));
        } else {

            data.insert("is_user_self", json!(false));
        }

        data.insert("is_login", json!(is_login));
        data.insert("cur_user", json!(user));

        respond_view("user", &data)
    }
}

pub fn update_user_info(req: &mut Request) -> IronResult<Response> {

    let params = get_request_body(req);
    let session = get_session_obj(req);
    let username = session["username"].as_str().unwrap();
    let register_source = session["register_source"].as_u64().unwrap();
    let old_avatar_url = session["avatar_url"].as_str().unwrap();
    let new_username = &params.get("username").unwrap()[0];
    let email = &params.get("email").unwrap()[0];

    let mut data = JsonData::new();

    if new_username == "" {

        data.success = false;
        data.message = "用户名不可为空！".to_owned();

        return respond_json(&data);
    }

    if email == "" {

        data.success = false;
        data.message = "邮箱不可为空！".to_owned();

        return respond_json(&data);
    }

    if new_username != username && is_user_created(new_username) {

        data.success = false;
        data.message = "该用户名已被注册！".to_owned();

        return respond_json(&data);
    }

    let avatar_url;

    if register_source == 1 {  // 如果是github用户，不更新头像

        avatar_url = old_avatar_url.to_string();
    } else {

        avatar_url = gen_gravatar_url(email);
    }

    let result = update_user(username, &json!({
        "username": new_username.to_string(),
        "github_account": params.get("githubAccount").unwrap()[0],
        "site": params.get("site").unwrap()[0],
        "qq": params.get("qq").unwrap()[0],
        "email": email.to_string(),
        "avatar_url": avatar_url,
        "location": params.get("location").unwrap()[0],
        "signature": params.get("signature").unwrap()[0]
    }));

    if result.is_none() {

        data.success = false;
        data.message = "用户信息设置失败！".to_owned();

        return respond_json(&data);
    }

    data.data = json!("/login");

    req.session().clear().unwrap();

    respond_json(&data)
}

pub fn change_password(req: &mut Request) -> IronResult<Response> {

    let params = get_request_body(req);
    let session = get_session_obj(req);
    let username = session["username"].as_str().unwrap();
    let old_password = &params.get("oldPassword").unwrap()[0];
    let new_password = &params.get("newPassword").unwrap()[0];
    let username_wrapper = check_user_login(username, old_password);

    let mut data = JsonData::new();

    if username_wrapper.is_none() {

        data.success = false;
        data.message = "您输入的当前密码不正确！".to_owned();

        return respond_json(&data);
    }

    let result = update_password(username, new_password);

    if result.is_none() {

        data.success = false;
        data.message = "密码更改失败，请重新尝试！".to_owned();

        return respond_json(&data);
    } else {

        data.data = json!("/login");

        req.session().clear().unwrap();

        respond_json(&data)
    }
}
