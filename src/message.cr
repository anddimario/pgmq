class QueueItem
  getter message : JSON::PullParser
  getter msg_id : Int64
  getter read_ct : Int32
  getter enqueued_at : Time
  getter vt : Time

  # Represents a queue item in the system.
  #
  # @param msg_id [Int64] The ID of the message.
  # @param read_ct [Int32] The number of times the message has been read.
  # @param enqueued_at [Time] The time when the message was enqueued.
  # @param vt [Time] The time when the message was last visited.
  # @param message [String] The content of the message.
  def initialize(@msg_id : Int64, @read_ct : Int32, @enqueued_at : Time, @vt : Time, @message : JSON::PullParser)
  end
end

class Message
  private getter conn : DB::Database
  private getter queue : Queue

  def initialize(conn_string : String, queue : Queue)
    @conn = DB.open(conn_string)
    @queue = queue
  end

  # Sends a message to the specified queue.
  #
  # @param message [String] the message to send
  # @raises [Exception] if there is an error sending the message
  def send(message : String)
    begin
      @conn.exec("SELECT * from pgmq.send($1, $2)", queue.@name, message)
    rescue exception
      raise "Error sending message: #{exception.message}"
    end
  end

  # Reads messages from the queue.
  #
  # This method reads messages from the queue using the specified parameters.
  # By default, it reads one message with a timeout of 30 seconds.
  #
  # @param invisible [Int32] The time in seconds that the message should remain invisible after being read.
  # @param quantity [Int32] The number of messages to read.
  # @return [Array] An array of messages read from the queue.
  # @raise [Exception] If there is an error reading the message.
  def read(invisible : Int32 = 30, quantity : Int32 = 1)
    begin
      @conn.query("SELECT * FROM pgmq.read($1, $2, $3);", queue.@name, invisible, quantity) do |rs|
        items = [] of QueueItem
        rs.each do
          items << QueueItem.new(rs.read(Int64), rs.read(Int32), rs.read(Time), rs.read(Time), rs.read(JSON::PullParser))
        end
        items
      end
    rescue exception
      raise "Error read message: #{exception.message}"
    end
  end

  # FILEPATH: /home/and/work/personal/pgmq/src/message.cr

  # Pop a message from the queue.
  #
  # This method executes a SQL query to retrieve a message from the queue
  # using the `pgmq.pop` function. It then constructs a `QueueItem` object
  # for each row returned by the query and adds it to the `items` array.
  #
  # @return [Array(QueueItem)] The array of popped messages.
  # @raise [String] If an error occurs while popping a message.
  def pop()
    begin
      @conn.query("SELECT * FROM pgmq.pop($1);", queue.@name) do |rs|
        items = [] of QueueItem
        rs.each do
          items << QueueItem.new(rs.read(Int64), rs.read(Int32), rs.read(Time), rs.read(Time), rs.read(JSON::PullParser))
        end
        items
      end
    rescue exception
      raise "Error pop message: #{exception.message}"
    end
  end

  # Deletes a message from the queue.
  #
  # @param msg_ids [Array(Int64)] the IDs of the message to delete
  # @raises [Exception] if there is an error deleting the message
  def delete(msg_ids : Array(Int64))
    begin
      # There are two function delete, so to avoid error, we need to specify the type for each parameter
      @conn.exec("SELECT * FROM pgmq.delete($1::text, $2::integer[])", queue.@name, msg_ids)
    rescue exception
      raise "Error deleting message: #{exception.message}"
    end
  end

  # Archives the specified message IDs in the queue.
  #
  # @param msg_ids [Array(Int64)] The array of message IDs to be archived.
  # @return [Nil] Returns nil if the archiving is successful.
  # @raise [String] Raises an error message if there is an error archiving the message.
  def archive(msg_ids : Array(Int64))
    begin
      # There are two function archive, so to avoid error, we need to specify the type for each parameter
      @conn.exec("SELECT * FROM pgmq.archive($1::text, $2::integer[])", queue.@name, msg_ids)
    rescue exception
      raise "Error archiving message: #{exception.message}"
    end
  end
end
