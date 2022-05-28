M_NAME:=${M_NAME}

default:
	echo "make g M_NAME=user"

# 生成模块下的所有文件
g:
	pnpm run nest g mo --no-spec ${M_NAME} module
	pnpm run nest g r --no-spec ${M_NAME} module
	pnpm run nest g s --no-spec ${M_NAME} module