require "./spec_helper"

describe Pgmq do
  it "write and read from a queue" do
    message = {"msg": "test message"}.to_json
    pgmq_queue = Queue.new("postgres://postgres:postgres@localhost:5432/postgres", "test_queue")
    pgmq_queue.create_queue
    pgmq_message = Message.new("postgres://postgres:postgres@localhost:5432/postgres", pgmq_queue)
    pgmq_message.send(message)
    rs = pgmq_message.read
    rs[0].msg_id.should eq(1)
  end
end
