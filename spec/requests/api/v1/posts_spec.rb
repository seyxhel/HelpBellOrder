require 'swagger_helper'

RSpec.describe 'api/v1/posts', type: :request do
  path '/api/v1/posts' do
    get('list posts') do
      tags 'Posts'
      description 'Retrieves all posts'
      produces 'application/json'
      
      response(200, 'successful') do
        schema type: :array,
               items: {
                 type: :object,
                 properties: {
                   id: { type: :integer, example: 1 },
                   title: { type: :string, example: 'My First Post' },
                   content: { type: :string, example: 'This is the content of my post...' },
                   author: { type: :string, example: 'John Doe' },
                   created_at: { type: :string, format: :datetime, example: '2024-08-12T19:30:00Z' },
                   updated_at: { type: :string, format: :datetime, example: '2024-08-12T19:30:00Z' }
                 },
                 required: ['id', 'title', 'content']
               }
        run_test!
      end
    end

    post('create post') do
      tags 'Posts'
      description 'Creates a new post'
      consumes 'application/json'
      produces 'application/json'
      
      parameter name: :post, in: :body, schema: {
        type: :object,
        properties: {
          title: { type: :string, example: 'New Post Title' },
          content: { type: :string, example: 'Content of the new post...' },
          author: { type: :string, example: 'Jane Smith' }
        },
        required: ['title', 'content']
      }

      response(201, 'post created') do
        schema type: :object,
               properties: {
                 id: { type: :integer, example: 2 },
                 title: { type: :string, example: 'New Post Title' },
                 content: { type: :string, example: 'Content of the new post...' },
                 author: { type: :string, example: 'Jane Smith' },
                 created_at: { type: :string, format: :datetime },
                 updated_at: { type: :string, format: :datetime }
               }
        run_test!
      end

      response(422, 'invalid request') do
        schema type: :object,
               properties: {
                 errors: {
                   type: :object,
                   properties: {
                     title: { type: :array, items: { type: :string } },
                     content: { type: :array, items: { type: :string } }
                   }
                 }
               }
        run_test!
      end
    end
  end

  path '/api/v1/posts/{id}' do
    parameter name: :id, in: :path, type: :integer, description: 'Post ID'

    get('show post') do
      tags 'Posts'
      description 'Retrieves a specific post'
      produces 'application/json'

      response(200, 'post found') do
        schema type: :object,
               properties: {
                 id: { type: :integer, example: 1 },
                 title: { type: :string, example: 'My First Post' },
                 content: { type: :string, example: 'This is the content of my post...' },
                 author: { type: :string, example: 'John Doe' },
                 created_at: { type: :string, format: :datetime },
                 updated_at: { type: :string, format: :datetime }
               }
        run_test!
      end

      response(404, 'post not found') do
        schema type: :object,
               properties: {
                 error: { type: :string, example: 'Post not found' }
               }
        run_test!
      end
    end

    put('update post') do
      tags 'Posts'
      description 'Updates a specific post'
      consumes 'application/json'
      produces 'application/json'
      
      parameter name: :post, in: :body, schema: {
        type: :object,
        properties: {
          title: { type: :string, example: 'Updated Post Title' },
          content: { type: :string, example: 'Updated content...' },
          author: { type: :string, example: 'John Doe' }
        }
      }

      response(200, 'post updated') do
        schema type: :object,
               properties: {
                 id: { type: :integer },
                 title: { type: :string },
                 content: { type: :string },
                 author: { type: :string },
                 created_at: { type: :string, format: :datetime },
                 updated_at: { type: :string, format: :datetime }
               }
        run_test!
      end

      response(404, 'post not found') do
        run_test!
      end

      response(422, 'invalid request') do
        run_test!
      end
    end

    delete('delete post') do
      tags 'Posts'
      description 'Deletes a specific post'

      response(204, 'post deleted') do
        run_test!
      end

      response(404, 'post not found') do
        run_test!
      end
    end
  end
end