import { Form, Input, Checkbox, Button } from "antd"
import { useCallback } from "react"
import { useNavigate } from "react-router-dom"
import { sdk } from "../../apollo"
import { RegisterInput } from '../../generated/graphql'
import { useDenyLogined } from "../../utils/hook"

export const RegisterPage = () => {
  useDenyLogined()

  let navigate = useNavigate();

  const onFinish = useCallback(async (values: any) => {
    const inputData: RegisterInput = {
      username: values.username,
      password: values.password,
      email: values.email,
      phone: values.phone,
    }
    const {data} = await sdk.registerUserMutation({
      variables: {
        registerData: inputData
      }
    });
    if (data?.registerUser.id) {
      navigate('/login')
    }
  }, [])

  return <Form
    name="basic"
    labelCol={{ span: 8 }}
    wrapperCol={{ span: 8 }}
    style={{marginTop: 80, padding: 20}}
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

    <Form.Item
      label="邮箱"
      name="email"
    >
      <Input />
    </Form.Item>

    <Form.Item
      label="手机号"
      name="phone"
    >
      <Input />
    </Form.Item>

    <Form.Item wrapperCol={{ offset: 8, span: 16 }}>
      <Button type="primary" htmlType="submit">
        注册
      </Button>
      <Button type="text"  href="/login">
        登录
      </Button>
    </Form.Item>
  </Form>
}