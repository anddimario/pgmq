class QueueMetrics
  def initialize(@queue_name : String, @queue_lenght : Int64, @newest_msg_age_sec : Int32 | Nil, @oldest_msg_age_sec : Int32 | Nil, @total_messages : Int64)
  end
end

class Queue
  private getter conn : DB::Database
  private getter name : String

  def initialize(conn_string : String, name : String)
    @conn = DB.open(conn_string)
    @name = name
  end

  # Creates a queue.
  #
  # This method executes a SQL query to create a queue using the `pgmq.create` function.
  # It takes no arguments and returns nothing.
  # If an exception occurs during the execution of the query, it raises an error with the exception message.
  def create_queue
    begin
      @conn.exec("SELECT pgmq.create($1)", @name)
    rescue exception
      raise "Error create queue: #{exception.message}"
    end
  end

  # Retrieves the count of items in the specified queue.
  #
  # @return [Int64] The count of items in the queue.
  # @raise [Exception] If there is an error creating the queue.
  def archive_count
    begin
      @conn.query_one("SELECT COUNT(*) FROM pgmq.a_#{@name}", as: Int64)
    rescue exception
      raise "Error archive count queue: #{exception.message}"
    end
  end

  # Retrieves the metrics of the queue.
  #
  # This method queries the database to retrieve various metrics of the queue, including the queue name,
  # queue length, newest message age in seconds, oldest message age in seconds, and total number of messages.
  #
  # @return [Tuple(String, Int64, Int32, Int32, Int64)] The metrics of the queue (queue_name, queue_length, newest_msg_age_sec, oldest_msg_age_sec, total_messages).
  # @raise [Exception] If there is an error while retrieving the metrics.
  def metrics
    begin
      @conn.query_one("SELECT queue_name, queue_length, newest_msg_age_sec, oldest_msg_age_sec, total_messages FROM pgmq.metrics($1)", @name, as: {String, Int64, Int32, Int32, Int64})
    rescue exception
      raise "Error metric queue: #{exception.message}"
    end
  end

  # Purges all messages from the queue.
  #
  # This method executes a SQL query to remove all messages from the queue
  # specified by the `@name` instance variable.
  #
  # @raises [Exception] if there is an error purging the queue
  def purge
    begin
      @conn.exec("SELECT * FROM pgmq.purge_queue($1)", @name)
    rescue exception
      raise "Error purge queue: #{exception.message}"
    end
  end

  # Drops the queue from the database.
  #
  # This method executes the SQL query to drop the queue using the `pgmq.drop_queue` function.
  # If an exception occurs during the execution of the query, an error message is raised.
  #
  # @raises [Exception] if an error occurs during the execution of the query.
  def drop
    begin
      @conn.exec("SELECT * FROM pgmq.drop_queue($1)", @name)
    rescue exception
      raise "Error drop queue: #{exception.message}"
    end
  end
end
