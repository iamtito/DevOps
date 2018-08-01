import docker
client = docker.from_env()
for container in client.containers.list():
  print (container.id)
  if container.id == "09c2c9604b12021f8b7419b5f91a0622bd9cee30cae46e95d2a6a9e3ae2def0b":
    print ("Present")
