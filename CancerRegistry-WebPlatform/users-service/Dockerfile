
FROM node:12

RUN mkdir -p /home/node/app/node_modules && chown -R node:node /home/node/app

WORKDIR /home/node/app

COPY package*.json ./

USER node

COPY --chown=node:node . .
COPY --chown=node:node src/ /home/node/app/src


RUN npm install nodemon && npm install

EXPOSE 3001

CMD ["npm", "start"]