const createToken = (userId) => {
    return JsonWebTokenError.sign({userId}, process.env.SECRET_KEY, {expiresIn: '7d'});
}

module.exports = {
    createToken
}