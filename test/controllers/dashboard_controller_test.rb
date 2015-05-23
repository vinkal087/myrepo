require 'test_helper'

class DashboardControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get images" do
    get :images
    assert_response :success
  end

  test "should get cvms" do
    get :cvms
    assert_response :success
  end

  test "should get users" do
    get :users
    assert_response :success
  end

end
