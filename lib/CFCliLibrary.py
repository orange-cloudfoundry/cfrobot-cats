import os
import shutil
import tempfile
import zipfile

import urllib3
from robot.libraries.Process import Process

urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)


class CFCliLibrary(object):

    def __init__(self):
        print("used")
        os.makedirs("./.cf_home", exist_ok=True)
        self._process = Process()

    def login(self, api, user, password, skip_ssl=False):
        api_cmd = ["api", api]
        if skip_ssl:
            api_cmd.append("--skip-ssl-validation")
        self.cf(*api_cmd)
        auth_cmd = ["auth", user, password]
        return self.cf(*auth_cmd)

    def cf(self, *arguments, **configuration):
        configuration["env:CF_HOME"] = "./.cf_home"
        result = self._process.run_process("cf", *arguments, **configuration)
        result_msg = result.stdout
        if result_msg is None:
            result_msg = result.stderr
        elif result.stderr is not None:
            result_msg += result.stderr
        if result.rc != 0:
            raise AssertionError(result_msg)
        return result_msg

    def target(self, org, space=None):
        target_cmd = ["target", "-o", org]
        if space is not None:
            target_cmd.append("-s")
            target_cmd.append(space)
        return self.cf(*target_cmd)

    def create_org_with_space_and_target(self, org, space):
        self.cf("create-org", org)
        self.cf("create-space", space, "-o", org)
        return self.target(org, space)

    def get_first_buildpack(self, name):
        result = self.cf(*["buildpacks"])
        for line in result.splitlines():
            if line.startswith(name):
                return line.split()[0]
        raise AssertionError('Buildpack with {} does not exists'.format(name))

    def delete_org(self, org):
        return self.cf("delete-org", "-f", org)

    def download_and_extract_app(self, appname):
        tfile = tempfile.mkstemp(prefix="cfrobot-cats")
        (fd, filename) = tfile
        os.close(fd)
        tdir = tempfile.mkdtemp(prefix="cfrobot-cats")
        try:
            app_guid = self.cf("app", appname, "--guid")
            self.cf("curl", '/v2/apps/{}/download'.format(app_guid), "--output", filename,
                    **{'stdout': 'DEVNULL', 'stderr': 'DEVNULL'})
            with zipfile.ZipFile(filename, "r") as zip_ref:
                zip_ref.extractall(tdir)
        except Exception as e:
            shutil.rmtree(tdir, ignore_errors=True)
            raise e
        finally:
            os.remove(filename)
        return tdir

    def cleanup(self, kill=False):
        self._process.terminate_all_processes(kill)
