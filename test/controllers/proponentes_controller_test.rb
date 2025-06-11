require "test_helper"

class ProponentesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get proponentes_index_url
    assert_response :success
  end

  test "should get show" do
    get proponentes_show_url
    assert_response :success
  end

  test "should get new" do
    get proponentes_new_url
    assert_response :success
  end

  test "should get create" do
    get proponentes_create_url
    assert_response :success
  end

  test "should get edit" do
    get proponentes_edit_url
    assert_response :success
  end

  test "should get update" do
    get proponentes_update_url
    assert_response :success
  end

  test "should get destroy" do
    get proponentes_destroy_url
    assert_response :success
  end
end
