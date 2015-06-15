class ImagesController < ApplicationController
  layout "image"
  
  def index
	@images = Image.sorted
	# Get presigned URLs for each image
    bucket = s3_bucket
	@imurl = Array[]
	@images.each do |image|
		@imurl << bucket.object(image.key).presigned_url(:get, expires_in: 3600)
	end
  end

  def show
	@image = Image.find(params[:id])
	@imurl = s3_bucket.object(@image.key).presigned_url(:get, expires_in: 3600)
  end

  def new
	# Send new Image instance with default values
	@image = Image.new
	# Prepare a Presigned Post object to allow the user to upload an image to the S3 bucket
	s3c = Aws::S3::Client.new
	@post_image = Aws::S3::PresignedPost.new(
		s3c.config[:credentials], 
		s3c.config[:region], 
		bucket_name,
		success_action_redirect:self.url_for(:action=>'create'), 
		key:'${filename}'
		# content_type_starts_with: 'image/'
	)
  end
 
  def create
	# Instantiate a new Image using form parameters
	@image = Image.new
	@image[:key] = params[:key]
	# Save the image
	if @image.save
		# If save succeeds, redirect to the index action
		flash[:notice] = "Image uploaded successfully"
		redirect_to(:action => 'edit', :id => @image.id)
	else
		# If save fails, redisplay the form so user can fix problems
		flash[:error] = "Image failed to upload. Please try again."
		render('new')
	end
  end

  def edit
	@image = Image.find(params[:id])
	@imurl = s3_bucket.object(@image.key).presigned_url(:get, expires_in: 3600)
  end

  def update
	# Find Image using form parameters
	@image = Image.find(params[:id])
	# Update the image
	if @image.update_attributes(image_params)
		# If update succeeds, redirect to the index action
		flash[:notice] = "Image details updated successfully"
		redirect_to(:action => 'show', :id => @image.id)
	else
		# If update fails, redisplay the form so user can fix problems
		flash[:error] = "Image details not yet uploaded"
		render('edit')
	end
  end

  def delete
	@image = Image.find(params[:id])
	@imurl = s3_bucket.object(@image.key).presigned_url(:get, expires_in: 3600)
  end
  
  def destroy
	image_tmp = Image.find(params[:id])
	resp = s3_bucket.object(image_tmp.key).delete # stopped working...
	image = image_tmp.destroy
	flash[:notice] = "Image '#{image.caption}' destroyed successfully"
	redirect_to(:action => 'index')
  end

  private def image_params
	params.require(:image).permit(:key, :caption, :description, :alt_text)
  end
  
  private def s3_bucket
	Aws::S3::Resource.new.bucket("codingtest-chryckie")
  end
  
  private def bucket_name
    'codingtest-chryckie'
  end
end
