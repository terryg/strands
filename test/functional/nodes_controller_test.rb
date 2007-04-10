require File.dirname(__FILE__) + '/../test_helper'
require 'nodes_controller'

# Re-raise errors caught by the controller.
class NodesController; def rescue_action(e) raise e end; end

class NodesControllerTest < Test::Unit::TestCase
  fixtures :nodes

  def setup
    @controller = NodesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = nodes(:first).id
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'list'
  end

  def test_list
    get :list

    assert_response :success
    assert_template 'list'

    assert_not_nil assigns(:nodes)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:node)
    assert assigns(:node).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:node)
  end

  def test_create
    num_nodes = Node.count

    post :create, :node => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_nodes + 1, Node.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:node)
    assert assigns(:node).valid?
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
  end

  def test_destroy
    assert_nothing_raised {
      Node.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      Node.find(@first_id)
    }
  end
end
