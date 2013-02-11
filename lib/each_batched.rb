
require 'valium'

#
# More grouping/batching logic options than what's included in Rails.
#

module EachBatched
  
  # Default batch size to use, if none is specified (defaults to 1000)
  DEFAULT_BATCH_SIZE = 1_000
  
  # Yields batches of records from the current scope.
  # Uses offset/limit internally to run through each batch,
  # and can be further restricted by in-scope offset/limit/order (it doesn't just toss them out!).
  # 
  # * This algorithm does NOT work well with data that may have inserts/deletes while you're looping,
  #   so if that's a problem, then you should either lock the table or rows first or use a different algorithm
  #   (like ActiveRecord::Batches#find_in_batches or #batches_by_ids).
  # * This algorithm may be slower than #batches_by_ids if your query doesn't execute very quickly.
  # * This algorithm can't be lazily loaded, because it checks for empty results to see when it's done.
  def batches_by_range(batch_size=DEFAULT_BATCH_SIZE)
    start_offset = scoped.offset_value || 0
    end_limit = scoped.limit_value # || nil
    group_number = 0
    processed_number = 0
    # This giant while condition (with multiple assignments in it) is a mess, isn't it!
    # But simplifying it means I have to repeat most of it multiple times!
    # And putting it into a subroutine doesn't really save space either, with lots of parameters and/or return values!
    while (length = (records = offset(start_offset + batch_size * group_number).
        limit(asked_limit = end_limit.nil? || processed_number + batch_size < end_limit ?
          batch_size : end_limit - processed_number)).length) > 0
      yield records
      processed_number += length
      break if length < asked_limit || (! end_limit.nil? && processed_number >= end_limit)
      group_number += 1
    end
  end
  
  # Loops through each individual row found by #batches_by_range, instead of each batch
  # see #batches_by_range for an explanation of its algorithm
  def each_by_range(batch_size=DEFAULT_BATCH_SIZE)
    batches_by_range(batch_size) { |batch| batch.each { |row| yield row } }
  end
  
  # Yields batches of records from the current scope
  # Snapshots the primary key ids in scope, then loops through grabbing the rows, one chunk of ids at a time.
  #
  # * You should explicitly set an order if you want the same order as #batches_by_range, or it may be different.
  # * The yielded scope can be lazily loaded (though the id selection query has already run obviously)
  # * You can optionally give it some column other than the primary key to use, as long as it's guaranteed unique
  def batches_by_ids(batch_size=DEFAULT_BATCH_SIZE, key=nil)
    reduced_scope = scoped.tap { |s| s.where_values = [] }.offset(nil).limit(nil)
    key = primary_key if key.nil?
    # valium's value_of is way faster than select...collect...
    #select("#{table_name}.#{key}").collect(&(key.to_sym)).in_groups_of(batch_size, false) do |group_ids|
    scoped.value_of(key).in_groups_of(batch_size, false) do |group_ids|
      # keeps select/group/joins/includes, inside inner batched scope
      yield reduced_scope.where(key => group_ids)
    end
  end
  
  # Loops through each individual row found by #batches_by_ids, instead of each batch
  # see #batches_by_ids for an explanation of its algorithm
  def each_by_ids(batch_size=DEFAULT_BATCH_SIZE, key=nil)
    batches_by_ids(batch_size, key) { |batch| batch.each { |row| yield row } }
  end
  
end

# add all this functionality to ActiveRecord for all models to use
ActiveRecord::Base.extend EachBatched
