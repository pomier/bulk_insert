require 'test_helper'

class BulkInsertTest < ActiveSupport::TestCase
  test "bulk_insert without block should return worker" do
    result = Testing.bulk_insert
    assert_kind_of BulkInsert::Worker, result
  end

  test "bulk_insert with block should yield worker" do
    result = nil
    Testing.bulk_insert { |worker| result = worker }
    assert_kind_of BulkInsert::Worker, result
  end

  test "bulk_insert with block should save automatically" do
    assert_difference "Testing.count", 1 do
      Testing.bulk_insert do |worker|
        worker.add greeting: "Hello"
      end
    end
  end

  test "worker should not have any result sets without option for returning primary keys" do
    worker = Testing.bulk_insert
    worker.add greeting: "hello"
    worker.save!
    assert_empty worker.result_sets
  end

  test "with option to return primary keys, worker should have result sets" do
    worker = Testing.bulk_insert(return_primary_keys: true)
    worker.add greeting: "yo"
    worker.save!
    assert_equal 1, worker.result_sets.count
  end

  test "bulk_insert with array should save the array immediately" do
    assert_difference "Testing.count", 2 do
      result = Testing.bulk_insert values: [
        [ "Hello", 15, true ],
        { greeting: "Hey", age: 20, happy: false }
      ]
      assert_nil result
    end
  end

  test "bulk_insert with an empty value should not return worker" do
    assert_nil Testing.bulk_insert values: []
  end

  test "bulk_insert with option to return primary keys and values should return the new ids" do
    output = Testing.bulk_insert(
      values: [["Hello", 15, true]],
      return_primary_keys: true
    )
    assert_equal output, []
  end

  test "default_bulk_columns should return all columns without id" do
    default_columns = %w(greeting age happy created_at updated_at color)

    assert_equal Testing.default_bulk_columns, default_columns
  end

end
