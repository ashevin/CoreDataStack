Pod::Spec.new do |s|
  s.name             = 'SimpleCoreDataStack'
  s.version          = '0.1.6'
  s.summary          = 'A safe, simple, easy-to-use, Core Data stack for iOS.'
  s.description      = <<-DESC
  CoreDataStack provides a simple all-in-one Core Data stack. It is designed to make Core Data both safe and easy to use. For applications which require high performance, via multiple writers, this project is not for you.
  CoreDataStack provides a readonly NSManagedObjectContext for use in the main thread. Contexts for writing are vended as needed, and work is serialized on a background queue.
                       DESC
  s.homepage         = 'https://github.com/ashevin/CoreDataStack.git'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Avi Shevin' => 'avi.github@mail.ashevin.com' }
  s.source           = { :git => 'https://github.com/ashevin/CoreDataStack.git', :tag => s.version.to_s }
  s.ios.deployment_target = '8.0'
  s.source_files     = 'CoreDataStack/CoreDataStack/Source/*.swift'
  s.module_name      = 'CoreDataStack'
end

