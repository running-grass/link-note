import { Form, Input, Button } from "antd";
import { useCallback } from "react";
import { useNavigate } from "react-router-dom";
import axios  from 'axios'


import { sdk } from "../../apollo";


export const LoginPage = () => {
  let navigate = useNavigate();

  const onFinish = useCallback(async (values: any) => {
    try {
      const {data,status, statusText} = await axios.post("/api/auth/login", {
        username: values.username,
        password: values.password,
      })
      if (status === 200 || status === 201) {
        localStorage.setItem('access_token', data.access_token)
        // alert('登录成功')
      } else {
        alert(statusText)
      }
    } catch {
      console.error('登录失败')
    }
  }, [])

  return <Form
    name="basic"
    labelCol={{ span: 8 }}
    wrapperCol={{ span: 8 }}
    onFinish={onFinish}
    autoComplete="off"
  >
    <Form.Item
      label="用户名"
      name="username"
      rules={[{ required: true, message: 'Please input your username!' }]}
    >
      <Input />
    </Form.Item>

    <Form.Item
      label="密码"
      name="password"
      rules={[{ required: true, message: 'Please input your password!' }]}
    >
      <Input.Password />
    </Form.Item>


    <Form.Item wrapperCol={{ offset: 8, span: 16 }}>
      <Button type="primary" htmlType="submit">
        登录
      </Button>
    </Form.Item>
  </Form>
}