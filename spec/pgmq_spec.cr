require "./spec_helper"

describe Pgmq do
  pgmq_queue = Queue.new("postgres://postgres:postgres@localhost:5432/postgres", "test_queue")
  pgmq_message = Message.new("postgres://postgres:postgres@localhost:5432/postgres", pgmq_queue)
  message = {"msg": "test message"}.to_json

  it "message actions" do
    pgmq_queue.create_queue
    pgmq_message.send(message)
    pgmq_message.send(message)
    rs = pgmq_message.read
    rs[0].msg_id.should eq(1)
    pgmq_message.delete([rs[0].msg_id])

    rs_for_archive = pgmq_message.read
    rs_for_archive[0].msg_id.should eq(2)
    pgmq_message.archive([rs_for_archive[0].msg_id])
  end

  it "pop" do
    pgmq_message.send(message)
    rs = pgmq_message.pop
    rs[0].msg_id.should eq(3)
  end

  it "queue actions" do
    pgmq_message.send(message)
    pgmq_queue.archive_count.should eq(1)
    rs = pgmq_queue.metrics
    rs[4].should eq(4)
    pgmq_queue.purge
    pgmq_queue.drop
  end
end
