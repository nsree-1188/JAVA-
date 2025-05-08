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

    Developer(String name) {
        this.name = name;
    }

    public void showDeveloper() {
        System.out.println("Developer Name: " + name);
    }
}

class ITMain {
    public static void main(String args[]) {
        Developer dev = new Developer("Arjun");
        Project proj = new Project("Inventory System");

        dev.showDeveloper();
        proj.showProject();
    }
}
