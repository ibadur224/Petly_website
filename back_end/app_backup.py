from flask import Flask, render_template, redirect, url_for, flash, request, send_from_directory
from flask_sqlalchemy import SQLAlchemy
from flask_login import LoginManager, UserMixin, login_user, logout_user, login_required, current_user
from werkzeug.security import generate_password_hash, check_password_hash
from datetime import datetime
import os

# Initialize app with custom template folder
base_dir = r'E:\not your bissnus\Petly\site'
template_dir = os.path.join(base_dir, 'front_end', 'auth')

app = Flask(__name__, template_folder=template_dir)
app.config['SECRET_KEY'] = 'ibadur_petly_auth_2026_secure_key_983742'
app.config['SQLALCHEMY_DATABASE_URI'] = 'mysql+mysqlconnector://root:@localhost/petly_db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

# Initialize extensions
db = SQLAlchemy(app)
login_manager = LoginManager(app)
login_manager.login_view = 'login'

# User model
class User(db.Model, UserMixin):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(50), unique=True, nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)
    password_hash = db.Column(db.String(255), nullable=False)
    is_admin = db.Column(db.Boolean, default=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

@login_manager.user_loader
def load_user(user_id):
    return User.query.get(int(user_id))

# Serve static files from multiple locations
@app.route('/assets/<path:filename>')
def assets(filename):
    locations = [
        os.path.join(base_dir, 'resourses'),
        os.path.join(base_dir, 'front_end', 'auth'),
        os.path.join(os.path.dirname(__file__), 'static')
    ]
    
    for location in locations:
        file_path = os.path.join(location, filename)
        if os.path.exists(file_path):
            return send_from_directory(location, filename)
    
    return 'File not found', 404

# Also serve default static files
@app.route('/static/<path:filename>')
def static_files(filename):
    return send_from_directory(os.path.join(os.path.dirname(__file__), 'static'), filename)

# Routes
@app.route('/')
def index():
    return redirect(url_for('login'))

@app.route('/signup', methods=['GET', 'POST'])
def signup():
    if current_user.is_authenticated:
        return redirect(url_for('profile'))
    
    if request.method == 'POST':
        username = request.form.get('username')
        email = request.form.get('email')
        password = request.form.get('password')
        confirm_password = request.form.get('confirm_password')
        
        # Validation
        if not all([username, email, password, confirm_password]):
            flash('All fields are required', 'danger')
        elif password != confirm_password:
            flash('Passwords do not match', 'danger')
        elif len(password) < 6:
            flash('Password must be at least 6 characters', 'danger')
        else:
            # Check if user exists
            user_exists = User.query.filter((User.username == username) | (User.email == email)).first()
            if user_exists:
                flash('Username or email already exists', 'danger')
            else:
                # Create user
                hashed_password = generate_password_hash(password)
                user = User(
                    username=username, 
                    email=email, 
                    password_hash=hashed_password,
                    is_admin=(email == 'admin@petly.com')
                )
                db.session.add(user)
                db.session.commit()
                flash('Account created successfully! Please login.', 'success')
                return redirect(url_for('login'))
    
    return render_template('sign_up.html')

@app.route('/login', methods=['GET', 'POST'])
def login():
    if current_user.is_authenticated:
        return redirect(url_for('profile'))
    
    if request.method == 'POST':
        email = request.form.get('email')
        password = request.form.get('password')
        
        user = User.query.filter_by(email=email).first()
        if user and check_password_hash(user.password_hash, password):
            login_user(user, remember=request.form.get('remember'))
            flash('Login successful!', 'success')
            return redirect(url_for('profile'))
        else:
            flash('Invalid email or password', 'danger')
    
    return render_template('sign_in.html')

@app.route('/logout')
@login_required
def logout():
    logout_user()
    flash('You have been logged out', 'info')
    return redirect(url_for('login'))

@app.route('/profile')
@login_required
def profile():
    return render_template('profile.html', user=current_user)

@app.route('/admin/dashboard')
@login_required
def admin_dashboard():
    if not current_user.is_admin:
        flash('Admin access required', 'danger')
        return redirect(url_for('profile'))
    
    # Check if admin_dashboard.html exists in template folder
    admin_template = os.path.join(template_dir, 'admin_dashboard.html')
    if os.path.exists(admin_template):
        users = User.query.all()
        return render_template('admin_dashboard.html', users=users)
    else:
        flash('Admin dashboard template not found', 'danger')
        return redirect(url_for('profile'))

# Initialize database and create admin
with app.app_context():
    db.create_all()
    
    # Create admin user if not exists
    admin = User.query.filter_by(email='admin@petly.com').first()
    if not admin:
        admin_user = User(
            username='admin',
            email='admin@petly.com',
            password_hash=generate_password_hash('admin123'),
            is_admin=True
        )
        db.session.add(admin_user)
        db.session.commit()
        print('✓ Admin user created')
        print('  Email: admin@petly.com')
        print('  Password: admin123')
    else:
        print('✓ Admin user already exists')

if __name__ == '__main__':
    print('Starting Flask application...')
    print('URL: http://localhost:5000')
    print(f'Template folder: {template_dir}')
    print('Press Ctrl+C to stop\n')
    app.run(debug=True, port=5000)
