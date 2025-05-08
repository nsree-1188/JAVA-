class Project {
    String title;

    Project(String title) {
        this.title = title;
    }

    public void showProject() {
        System.out.println("Project Title: " + title);
    }
}

class Developer {
    String name;
    Project project; 

    Developer(String name, Project project) {
        this.name = name;
        this.project = project;
    }

    public void showDeveloper() {
        System.out.println("Developer Name: " + name);
        project.showProject();
    }
}

class ITMain {
    public static void main(String args[]) {
        Project proj = new Project("Inventory System");
        Developer dev = new Developer("Arjun", proj); 

        dev.showDeveloper();
    }
}

 
