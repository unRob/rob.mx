FROM node:lts-alpine

WORKDIR /var/lib/pdf-generator
RUN npm install puppeteer-core
COPY to-pdf.js .

ENTRYPOINT [ "node", "to-pdf.js" ]