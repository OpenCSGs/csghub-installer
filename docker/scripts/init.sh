#!/bin/bash

CURRENT_DIR=$(
   cd "$(dirname "$0")"
   pwd
)

# generate .lfs.opencsg.co folder
gen_lfs_folder(){
  destfolder=$lfs_folder_name

  mkdir $lfs_folder_name

  attfile=$lfs_folder_name/.gitattributes
  touch $attfile
  echo "* filter=lfs diff=lfs merge=lfs -text" >> $attfile

  for file in $(git lfs ls-files | awk {'print $3'}); do
     echo $file
     directory=$(dirname "$file")
     subfolder=$destfolder/$directory
     mkdir -p $subfolder
     cp $file $destfolder/$file
  done
}

# generate Dockerfile
gen_dockerfile(){

  file="Dockerfile-python$python_version"
  if [[ $device == 'gpu' ]]; then
    file=$file"-cuda11.8.0"
  fi

  echo "the Dockerfile is $file"

  sourcefile="$source_dir/$file"
  if [[  -f $sourcefile ]]; then
      cp $sourcefile  $repo/Dockerfile
  else
      echo "docker file $sourcefile is no exist"
      exit 1
  fi

}

gen_start_script(){

app_file="app.py"
  if [[ $sdk == 'gradio' ]]; then
      # echo "#!/bin/sh \n python3 app.py" > $repo/start_entrypoint.sh
      cat >  $repo/start_entrypoint.sh <<EOF
#!/bin/sh

python3 $app_file
EOF
  elif [[ $sdk == 'streamlit' ]]; then
      # echo "#!/bin/sh \n streamlit run app.py" > $repo/start_entrypoint.sh
      cat >  $repo/start_entrypoint.sh <<EOF
#!/bin/sh

streamlit run $app_file
EOF
  else 
      echo "not supported sdk $sdk"
      exit 1
  fi 

  chmod 755 $repo/start_entrypoint.sh
}

lfs_folder_name='.lfs.opencsg.co'

datafolder=$1
reponame=$2
username=$3
gittoken=$4
fullrepourl=$5 # must be http or https protocol
gitref=$6

sdk=$7
python_version=$8
device=$9  # cpu or gpu

source_dir=$CURRENT_DIR

if [[ ${fullrepourl:0:5} == "https" ]]; then
  modified_repourl=$(echo "$fullrepourl" | sed 's/https:\/\///')
  space_respository="https://"$username":"$gittoken"@"$modified_repourl
elif [[ ${fullrepourl:0:4} == "http" ]]; then
  modified_repourl=$(echo "$fullrepourl" | sed 's/http:\/\///')
  space_respository="http://"$username":"$gittoken"@"$modified_repourl
else
  echo "Invalid Git URL format: $fullrepourl"
  exit 1
fi
echo "the full space clone url is $space_respository"

repo=$datafolder"/$reponame"
git lfs install
export GIT_LFS_SKIP_SMUDGE=1
#git clone https://13581792646:6dbb294fce92283cd352a0dcecef1bca8ec2bf1b@portal.opencsg.com/models/13581792646/testspace.git  $repo
git clone $space_respository $repo
cd $repo
git checkout $gitref

if [[  ! $? -eq 0   ]]; then
  echo "failed to clone repo"
  exit 1
fi

cd $repo
## prepare repo
gen_lfs_folder
gen_dockerfile
gen_start_script

requirementsfile="$repo/requirements.txt"
if [ ! -f $requirementsfile ]; then
    touch $requirementsfile
    echo "requirements.txt is created"
fi

packagefile="$repo/packages.txt"
if [ ! -f $packagefile ]; then
    touch $packagefile
    echo "packages.txt is created"
fi

prerequirementsfile="$repo/pre-requirements.txt"
if [ ! -f $prerequirementsfile ]; then
    touch $prerequirementsfile
    echo "pre-requirements.txt is created"
fi

echo $space_respository > ./SPACE_REPOSITORY

rm -rf .git