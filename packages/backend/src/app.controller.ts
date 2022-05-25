import { Controller, Get, Post, UseGuards } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { Request } from '@nestjs/common'
import { AuthService } from './module/auth/auth.service';

@Controller()
export class AppController {
  constructor(
    private readonly authService: AuthService,
    ) {}

  @UseGuards(AuthGuard('local'))
  @Post('auth/login')
  async login(@Request() req) {
    return this.authService.login(req.user);
  }
}
