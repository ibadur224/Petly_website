from flask import Blueprint, render_template, redirect, url_for, flash, request, jsonify
from flask_login import login_user, logout_user, current_user, login_required
from . import db
from .models import User
from .forms import RegistrationForm, LoginForm
from .utils import hash_password, check_password, admin_required

auth = Blueprint('auth', __name__)
main = Blueprint('main', __name__)
admin = Blueprint('admin', __name__)

@auth.route('/signup', methods=['GET', 'POST'])
def signup():
    if current_user.is_authenticated:
        return redirect(url_for('main.profile'))
    
    form = RegistrationForm()
    if form.validate_on_submit():
        hashed_password = hash_password(form.password.data)
        user = User(
            username=form.username.data,
            email=form.email.data,
            password_hash=hashed_password
        )
        db.session.add(user)
        db.session.commit()
        flash('Account created successfully! You can now login.', 'success')
        return redirect(url_for('auth.login'))
    
    return render_template('sign_up.html', form=form)

@auth.route('/login', methods=['GET', 'POST'])
def login():
    if current_user.is_authenticated:
        return redirect(url_for('main.profile'))
    
    form = LoginForm()
    if form.validate_on_submit():
        user = User.query.filter_by(email=form.email.data).first()
        if user and check_password(user.password_hash, form.password.data):
            login_user(user)
            next_page = request.args.get('next')
            flash('Login successful!', 'success')
            return redirect(next_page) if next_page else redirect(url_for('main.profile'))
        else:
            flash('Login failed. Check email and password.', 'danger')
    
    return render_template('sign_in.html', form=form)

@auth.route('/logout')
@login_required
def logout():
    logout_user()
    flash('You have been logged out.', 'info')
    return redirect(url_for('auth.login'))

@main.route('/profile')
@login_required
def profile():
    return render_template('profile.html', user=current_user)

@admin.route('/dashboard')
@login_required
@admin_required
def dashboard():
    users = User.query.all()
    return render_template('admin_dashboard.html', users=users)

# API routes for AJAX if needed
@auth.route('/api/check_username', methods=['POST'])
def check_username():
    username = request.json.get('username')
    user = User.query.filter_by(username=username).first()
    return jsonify({'exists': user is not None})

@auth.route('/api/check_email', methods=['POST'])
def check_email():
    email = request.json.get('email')
    user = User.query.filter_by(email=email).first()
    return jsonify({'exists': user is not None})
