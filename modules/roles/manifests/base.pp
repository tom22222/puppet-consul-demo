# This is a base role
# All hosts get this configured
class roles::base {

  include ::digitalocean

  include ::profiles::stdpackages

}
