require 'ffaker'

Rails.logger.info "Creating users..."

User.create(
  first_name: 'John',
  last_name: 'Doe',
  email: 'john@tight.no',
  password: 'password'
)
print '.'

User.create(
  first_name: 'Jane',
  last_name: 'Roe',
  email: 'jane@tight.no',
  password: 'password'
)
print '.'

User.create(
  first_name: 'Ola',
  last_name: 'Nordmann',
  email: 'ola@tight.no',
  password: 'password',
  admin: true
)
print '.'

Rails.logger.info "Creating tasks..."

20.times do |t|
  Task.create(
    name: FFaker::Job.title
  )
  print '.'
end

Rails.logger.info "Creating assignments..."

20.times do |a|
  Assignment.create(
    user_id: User.pluck(:id).sample,
    task_id: Task.pluck(:id).sample
  )
  print '.'
end


