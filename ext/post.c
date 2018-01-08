#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>

#define DEBUG 0

void error(const char *msg)
{
  perror(msg);
  exit(-2);
}

void sendtransaction(const char *host,
                    int port,
                    const char *key,
                    const char *txid)
{
  char *message_fmt =
    "POST /callbacks/%s HTTP/1.0\r\n" \
    "Api-Key: %s\r\n" \
    "Content-Length: 0\r\n" \
    "Connection: close\r\n" \
    "\r\n";

  struct hostent *server;
  struct sockaddr_in serv_addr;
  int sockfd, bytes, sent, received, total;
  char message[1024], response[4096];

  sprintf(message, message_fmt, txid, key);

#if DEBUG
  printf("Request:\n%s\n", message);
#endif

  sockfd = socket(AF_INET, SOCK_STREAM, 0);
  if (sockfd < 0)
    error("ERROR opening socket");

  server = gethostbyname(host);
  if (server == NULL)
    error("ERROR, no such host");

  memset(&serv_addr,0,sizeof(serv_addr));
  serv_addr.sin_family = AF_INET;
  serv_addr.sin_port = htons(port);
  memcpy(&serv_addr.sin_addr.s_addr, server->h_addr, server->h_length);

  if (connect(sockfd, (struct sockaddr *)&serv_addr, sizeof(serv_addr)) < 0)
    error("ERROR connecting");

  total = strlen(message);
  sent = 0;
  do {
    bytes = write(sockfd, message + sent, total - sent);
    if (bytes < 0)
      error("ERROR writing message to socket");
    if (bytes == 0)
      break;
    sent += bytes;
  } while (sent < total);

  memset(response, 0, sizeof(response));
  total = sizeof(response) - 1;
  received = 0;
  do {
    bytes = read(sockfd,response+received,total-received);
    if (bytes < 0)
      error("ERROR reading response from socket");
    if (bytes == 0)
      break;
    received += bytes;
  } while (received < total);

  close(sockfd);

  if (received == total)
    error("ERROR storing complete response from socket");

#if DEBUG
  printf("Response:\n%s\n", response);
#endif
}

int main(int argc,char *argv[])
{
  int portno;
  char *host;
  char *txid;

  if (argc != 5) {
    printf("Parameters: <host> <port> <key> <txid>\n");
    exit(-1);
  }

  txid = argv[4];
  printf("Registering transaction: %s ...\n", txid);
  portno = strtol(argv[2], NULL, 10);

  sendtransaction(argv[1], portno, argv[3], txid);

  return 0;
}
