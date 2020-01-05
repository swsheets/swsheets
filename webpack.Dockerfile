FROM node:10.18-alpine

WORKDIR /app/assets

COPY assets/package.json assets/*yarn* ./

RUN yarn install

COPY . .

CMD ["yarn", "run", "build"]
