import { Form, Input, Button } from "antd";
import { useCallback } from "react";
import { useNavigate } from "react-router-dom";
import axios from 'axios'
import { useLocalStorage } from "react-use";

import { LSK_JWT_TOKEN } from "../../cons";
import { useDenyLogined } from "../../utils/hook";


export const LoginPage = () => {
  useDenyLogined()
  let navigate = useNavigate();
  const [, setToken] = useLocalStorage(LSK_JWT_TOKEN);

  const onFinish = useCallback(async (values: any) => {
    try {
      const { data, } = await axios.post("/api/auth/login", {
        username: values.username,
        password: values.password,
      })

      setToken(data.access_token);
      // localStorage.setItem('access_token', data.access_token)
      navigate('/')
    } catch {
      console.error('登录失败')
    }
  }, [])

  return <Form
    name="basic"
    labelCol={{ span: 8 }}
    wrapperCol={{ span: 8 }}
    onFinish={onFinish}
    style={{marginTop: 100, padding: 20}}
    autoComplete="off"
  >
    <Form.Item
      label="用户名"
      name="username"
      rules={[{ required: true, message: '请输入用户名' }]}
    >
      <Input />
    </Form.Item>

    <Form.Item
      label="密码"
      name="password"
      rules={[{ required: true, message: '请输入密码' }]}
    >
      <Input.Password />
    </Form.Item>


    <Form.Item wrapperCol={{ offset: 8, span: 16 }}>
      <Button type="primary" htmlType="submit">
        登录
      </Button>
      <Button type="text"  href="/register">
        注册
      </Button>
    </Form.Item>
  </Form>
}