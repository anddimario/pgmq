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
end
